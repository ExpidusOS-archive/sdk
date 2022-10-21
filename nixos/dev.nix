{ config, lib, pkgs, flake, ... }:
{
  environment.systemPackages = with pkgs; [
    flake.self.packages.${flake.target}
  ];
}
