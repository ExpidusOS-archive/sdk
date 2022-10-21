{ config, lib, pkgs, ... }:
let
  nixpkgs = import ../lib/nixpkgs.nix;
  loginMessage = "ExpidusOS Development Virtual Machine (EDVM)";
in
{
  imports = [
    (nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
    (nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
  ];

  virtualisation = {
    memorySize = 2048;
    cores = 2;
  };

  programs.xwayland.enable = true;
  hardware.opengl.enable = true;

  services.getty = {
    greetingLine = loginMessage;
    autologinUser = "developer";
  };

  services.openssh = {
    enable = true;
    banner = loginMessage;
    permitRootLogin = "without-password";
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  users.users.developer = {
    createHome = true;
    home = "/home/expidus-devel";
    description = "Development test user";
    extraGroups = [ "wheel" ];
    password = "developer";
    isNormalUser = true;
  };

  system.stateVersion = "22.05";
}
