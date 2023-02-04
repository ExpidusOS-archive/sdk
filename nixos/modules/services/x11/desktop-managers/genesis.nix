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
        genesis-i3-cfg = pkgs.writeText "genesis-i3.cfg" ''
          include ~/.config/i3/config.d/*.conf
          exec --no-startup-id ibus-daemon --xim -d -r
          exec genesis-shell -m gadgets
        '';

        genesis-i3 = pkgs.writeShellScriptBin "genesis-i3" ''
          exec i3 "$@" -c ${genesis-i3-cfg}
        '';

        genesis-i3-session = (pkgs.writeTextDir "share/xsessions/genesis-i3.desktop" ''
          [Desktop Entry]
          Name=Genesis i3 
          Comment=i3 with the Genesis Shell UI
          Exec=${genesis-i3}/bin/genesis-i3
          Type=Application
        '') // { providedSessions = [ "genesis-i3" ]; };
      in {
        environment.systemPackages = with pkgs; [ genesis-i3 genesis-i3-session genesis-shell ];
        services.xserver.displayManager.sessionPackages = [ genesis-i3-session ];
        services.xserver.windowManager.i3.enable = true;
      }))
    (mkIf (cfg.enable && cfg.sessions.sway.enable)
      (let
        genesis-sway-dbus-environment = pkgs.writeScript "genesis-sway-dbus-environment" ''
          dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
          systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
          systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
        '';

        genesis-sway-cfg = pkgs.writeText "genesis-sway.cfg" ''
          include ~/.config/sway/config.d/*

          exec ${genesis-sway-dbus-environment}
          exec --no-startup-id ibus-daemon --xim -d -r
          exec genesis-shell -m gadgets
        '';

        genesis-sway = pkgs.writeShellScriptBin "genesis-sway" ''
          exec ${pkgs.sway}/bin/sway "$@" -c ${genesis-sway-cfg}
        '';

        genesis-sway-session = (pkgs.writeTextDir "share/wayland-sessions/genesis-sway.desktop" ''
          [Desktop Entry]
          Name=Genesis Sway
          Comment=Sway with the Genesis Shell UI
          Exec=${genesis-sway}/bin/genesis-sway
          Type=Application
        '') // { providedSessions = [ "genesis-sway" ]; };
      in {
        environment.systemPackages = with pkgs; [ genesis-sway genesis-sway-session genesis-shell ];
        services.xserver.displayManager.sessionPackages = [ genesis-sway-session ];

        xdg.portal.wlr.enable = true;

        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
        };
      }))
    (mkIf service-cfg.shell.enable {
      hardware.pulseaudio.enable = mkDefault true;
      security.polkit.enable = true;
      services.gnome.evolution-data-server.enable = true;
      services.dbus.enable = true;
      services.colord.enable = mkDefault true;
      services.accounts-daemon.enable = true;
      services.upower.enable = config.powerManagement.enable;
      services.xserver.libinput.enable = mkDefault true;

      xdg.mime.enable = true;
      xdg.icons.enable = true;

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      networking.networkmanager.enable = mkDefault true;
      services.xserver.updateDbusEnvironment = true;

      environment.systemPackages =
        let
          mandatoryPackages = with pkgs; [ genesis-shell ];
          optionalPackages = with pkgs; [ gnome.adwaita-icon-theme ];
        in mandatoryPackages
          ++ utils.removePackagesByName optionalPackages config.environment.genesis.excludePackages;

      i18n.inputMethod = mkDefault {
        enabled = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ mozc ];
      };

      environment.pathsToLink = [
        "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
      ];
    })
  ];
}