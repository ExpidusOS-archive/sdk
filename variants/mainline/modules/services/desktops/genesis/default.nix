{ config, lib, pkgs, ... }:
with lib;
{
  options.programs.genesis = {
    enable = mkEnableOption (mdDoc "Next-generation desktop environment for ExpidusOS");
  };

  config = mkIf config.programs.genesis.enable {
    environment.systemPackages = with pkgs; [ expidus.genesis-shell ];

    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = true;
      };
    };

    services.xserver.enable = true;
    services.accounts-daemon.enable = true;
    services.upower.enable = true;
    security.polkit.enable = true;
    hardware.opengl.enable = mkDefault true;

    fonts = {
      fontDir.enable = true;
      enableDefaultPackages = true;
    };

    services.xserver.displayManager.job.execCmd = ''
      export PATH=${pkgs.expidus.genesis-shell}/bin:$PATH
      cd ${pkgs.expidus.genesis-shell}/app
      exec genesis_shell --login
    '';

    systemd.services.display-manager = {
      enable = true;

      wants = [
        "upower.service"
        "accounts-daemon.service"
      ];
    };
  };
}
