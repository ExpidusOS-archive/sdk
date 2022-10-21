{ config, lib, pkgs, flake, ... }:
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

  environment.systemPackages = with pkgs; [
    flake.self.packages.${flake.target}
  ];

  users.users.developer = {
    createHome = true;
    description = "Development test user";
    extraGroups = [ "wheel" ];
    password = "developer";
  };
}
