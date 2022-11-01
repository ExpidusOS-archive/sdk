{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.xserver.desktopManager.genesis;
  service-cfg = config.services.genesis;
in
{
  options = {
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

        genesis-sway-session = pkgs.writeTextDir "share/wayland-sessions/genesis-sway.desktop" ''
          [Desktop Entry]
          Name=Genesis Sway
          Comment=Sway with the Genesis Shell UI
          Exec=genesis-sway
          Type=Application
        '';

        genesis-sway = pkgs.writeShellScriptBin "genesis-sway" ''
          exec sway "$@" -c ${genesis-sway-cfg}/genesis-sway.cfg
        '';
      in {
        environment.systemPackages = with pkgs; [
          sway
          genesis-sway-dbus-environment
          genesis-sway-cfg
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
      services.xserver.displayManager.sessionPackages = [ pkgs.genesis-shell ];
      services.xserver.updateDbusEnvironment = true;

      environment.systemPackages = with pkgs; [ genesis-shell ];

      i18n.inputMethod = mkDefault {
        enabled = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ mozc ];
      };
    })
  ];
}
