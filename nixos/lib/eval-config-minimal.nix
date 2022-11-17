{ lib }:
let
  evalModules = {
    prefix ? [],
    modules ? [],
    specialArgs ? {},
  }: lib.evalModules {
    inherit prefix modules;
    specialArgs = {
      modulesPath = builtins.toString ../modules;
      inherit lib;
    } // specialArgs;
  };
in { inherit evalModules; }
