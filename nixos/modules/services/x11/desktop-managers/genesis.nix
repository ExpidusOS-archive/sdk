{ config, lib, pkgs, utils, ... }:
with lib;
let
  cfg = config.services.xserver.desktopManager.genesis;
  service-cfg = config.services.genesis;
in
{
  options = {
     environment.genesis.excludePackages = mkOption {
      default = [];
      example = literalExpression "[ pkgs.gnome.totem ]";
      type = types.listOf types.package;
      description = "Which packages Genesis should exclude from the default environment";
    };

    services.genesis = {
      shell.enable = mkEnableOption "Enable Genesis Shell";
    };

    services.xserver.desktopManager.genesis = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the Genesis desktop environment.";
      };

      sessions = {
        i3 = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Add an i3 session of Genesis Shell";
          };
        };
        sway = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Add a Sway session of Genesis Shell";
          };
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      system.nixos-generate-config.desktopConfiguration = [''
        services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.genesis.enable = true;
      ''];

      services.genesis.shell.enable = true;
    })
    (mkIf (cfg.enable && cfg.sessions.i3.enable)
      (let
        genesis-i3-cfg = pkgs.writeTextFile {
          name = "genesis-i3.cfg";
          text = ''
            include ~/.config/i3/config.d/*.conf
            exec genesis-shell -m gadgets
          '';
        };

        genesis-i3-session = (pkgs.writeTextDir "share/xsessions/genesis-i3.desktop" ''
          [Desktop Entry]
          Name=Genesis i3 
          Comment=i3 with the Genesis Shell UI
          Exec=genesis-i3
          Type=Application
        '') // { providedSessions = [ "genesis-i3" ]; };

        genesis-i3 = pkgs.writeShellScriptBin "genesis-i3" ''
          exec i3 "$@" -c ${genesis-i3-cfg}
        '';
      in {
        environment.systemPackages = with pkgs; [
          i3
          genesis-i3
          genesis-i3-session
        ];

        services.xserver.displayManager.sessionPackages = [ genesis-i3-session ];
        services.xserver.windowManager.i3.enable = true;
      }))
    (mkIf (cfg.enable && cfg.sessions.sway.enable)
      (let
        genesis-sway-dbus-environment = pkgs.writeShellScriptBin "genesis-sway-dbus-environment" ''
          dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
          systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
          systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
        '';

        genesis-sway-cfg = pkgs.writeTextFile {
          name = "genesis-sway.cfg";
          text = ''
            include ~/.config/sway/config.d/*

            exec genesis-sway-dbus-environment
            exec genesis-shell -m gadgets
          '';
        };

        genesis-sway-session = (pkgs.writeTextDir "share/wayland-sessions/genesis-sway.desktop" ''
          [Desktop Entry]
          Name=Genesis Sway
          Comment=Sway with the Genesis Shell UI
          Exec=genesis-sway
          Type=Application
        '') // { providedSessions = [ "genesis-sway" ]; };

        genesis-sway = pkgs.writeShellScriptBin "genesis-sway" ''
          exec sway "$@" -c ${genesis-sway-cfg}
        '';
      in {
        environment.systemPackages = with pkgs; [
          sway
          genesis-sway-dbus-environment
          genesis-sway
          genesis-sway-session
        ];

        xdg.portal.wlr.enable = true;

        services.xserver.displayManager.sessionPackages = [ genesis-sway-session ];
        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
        };
      }))
    (mkIf service-cfg.shell.enable {
      hardware.pulseaudio.enable = mkDefault true;
      security.polkit.enable = true;
      services.dbus.enable = true;
      services.colord.enable = mkDefault true;
      services.accounts-daemon.enable = true;
      services.upower.enable = config.powerManagement.enable;

      xdg.mime.enable = true;
      xdg.icons.enable = true;

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      networking.networkmanager.enable = mkDefault true;
      services.xserver.updateDbusEnvironment = true;

      environment.systemPackages =
        let
          mandatoryPackages = with pkgs; [ genesis-shell ];
          optionalPackages = with pkgs; [ adwaita-icon-theme ];
        in mandatoryPackages
          ++ utils.removePackagesByName optionalPackages config.environment.genesis.excludePackages;


      i18n.inputMethod = mkDefault {
        enabled = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ mozc ];
      };
    })
  ];
}
