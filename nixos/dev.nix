{ config, lib, pkgs, ... }:
let
  nixpkgs = import ../lib/nixpkgs.nix;
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
