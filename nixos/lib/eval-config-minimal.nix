{ lib }:
let
  evalModules = {
    prefix ? [],
    modules ? [],
    specialArgs ? {},
  }: lib.evalModules {
    inherit prefix modules;
    specialArgs = {
      modulesPath = "${lib.expidus.channels.nixpkgs}/nixos/modules";
      inherit lib;
    } // specialArgs;
  };
in { inherit evalModules; }
