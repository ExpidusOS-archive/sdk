{ lib }:
let
  evalModules = {
    prefix ? [],
    modules ? [],
    specialArgs ? {},
  }: lib.evalModules {
    inherit prefix modules;
    specialArgs = {
      modulesPath = lib.expidus.channels.nixpkgs;
      inherit lib;
    } // specialArgs;
  };
in { inherit evalModules; }
