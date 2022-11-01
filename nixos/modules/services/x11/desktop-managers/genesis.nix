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
    (mkIf service-cfg.shell.enable {
      hardware.pulseaudio.enable = mkDefault true;
      security.polkit.enable = true;
      services.colord.enable = mkDefault true;
      services.accounts-daemon.enable = true;
      services.upower.enable = config.powerManagement.enable;

      xdg.mime.enable = true;
      xdg.icons.enable = true;

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      networking.networkmanager.enable = mkDefault true;
      services.xserver.updateDbusEnvironment = true;

      environment.systemPackages = with pkgs; [ genesis-shell ];

      i18n.inputMethod = mkDefault {
        enabled = mkDefault "ibus";
        ibus.engines = mkDefault (with pkgs.ibus-engines; [ mozc ]);
      };
    })
  ];
}
