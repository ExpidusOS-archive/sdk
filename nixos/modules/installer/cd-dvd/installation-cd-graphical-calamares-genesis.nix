{ pkgs, ... }:
{
  imports = [ ./installation-cd-graphical-calamares.nix ];

  isoImage.edition = "genesis";

  services.xserver = {
    displayManager = {
      defaultSession = "genesis-sway";
      gdm = {
        enable = true;
        autoSuspend = false;
        wayland = true;
      };
      autoLogin = {
        enable = true;
        user = "nixos";
      };
    };
    desktopManager.genesis = {
      enable = true;
      sessions = {
        i3.enable = true;
        sway.enable = true;
      };
    };
  };
}
