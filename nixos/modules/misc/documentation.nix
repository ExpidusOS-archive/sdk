{ config, options, lib, pkgs, utils, modules, extraModules, specialArgs, ... }@self:
import "${lib.expidus.channels.nixpkgs}/nixos/modules/misc/documentation.nix" (self // {
  config = lib.recursiveUpdate config {
    system.nixos.release = lib.version;
  };
  pkgs = pkgs.appendOverlays [ (final: prev: {
    path = lib.expidus.channels.nixpkgs;
  }) ];
  modulesPath = "${lib.expidus.channels.nixpkgs}/nixos/modules";
  baseModules = import "${lib.expidus.channels.nixpkgs}/nixos/modules/module-list.nix";
})
