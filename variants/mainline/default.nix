{ channels, lib ? import ../../lib/extend.nix channels }@baseArgs:
{ lib ? baseArgs.lib,
  system ? builtins.currentSystem,
  pkgs ? import ../../pkgs/top-level/overlay.nix channels { inherit system; },
  baseModules ? import ./modules/default.nix channels,
  extraModules ? [],
  specialArgs ? {}
}@args:
with lib;
let
  fargs = {
    inherit (baseArgs) lib;
    system = null;
    pkgs = import ../../pkgs/top-level/overlay.nix channels { inherit system; };
    baseModules = import ./modules/default.nix channels;
    extraModules = [];
    specialArgs = {};
  } // args;

  modules = fargs.baseModules ++ fargs.extraModules;

  isCross = fargs.pkgs.buildPlatform != fargs.pkgs.hostPlatform;

  pkgsModule = rec {
    _file = ./default.nix;
    key = _file;
    config = {
      inherit (fargs) lib;

      _module.args = {
        pkgs = lib.mkForce fargs.pkgs;
      };

      nixpkgs.system = lib.mkDefault (if fargs.system != null then fargs.system else fargs.pkgs.system);
    };
  };

  evaledModules = evalModules {
    specialArgs = fargs.specialArgs // {
      inherit (fargs) lib;
    };
    modules = [ pkgsModule ] ++ modules;
  };

  failedAssertions = map (x: x.message) (filter (x: !x.assertion) evaledModules.config.assertions);
  config =
    if failedAssertions != [ ] then
      throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
    else
      evaledModules.config;
in evaledModules // { inherit config; }
