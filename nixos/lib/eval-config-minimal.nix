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
    } // specialArgs;
  };
in { inherit evalModules; }
