{ localSystem,
  crossSystem ? localSystem,
  config ? {},
  overlays ? [],
  crossOverlays ? [],
  lib ? import ../../../lib,
  stdenvStages ? import "${lib.expidus.channels.nixpkgs}/pkgs/stdenv",
  ...
} @ args:
let
  config0 = config;
  crossSystem0 = crossSystem;
in let
  inherit (lib) throwIfNot;

  checked =
    throwIfNot (lib.isList overlays) "The overlays argument to nixpkgs must be a list."
    lib.foldr (x: throwIfNot (lib.isFunction x) "All overlays passed to nixpkgs must be functions.") (r: r) overlays
    throwIfNot (lib.isList crossOverlays) "The crossOverlays argument to nixpkgs must be a list."
    lib.foldr (x: throwIfNot (lib.isFunction x) "All crossOverlays passed to nixpkgs must be functions.") (r: r) crossOverlays;

  localSystem = lib.systems.elaborate args.localSystem;

  crossSystem =
    if crossSystem0 == null || crossSystem0 == args.localSystem
    then localSystem
    else lib.systems.elaborate crossSystem0;

  config1 =
    if lib.isFunction config0
    then config0 { inherit pkgs; }
    else config0;

  configEval = lib.evalModules {
    modules = [
      ./config.nix
      ({ options, ... }: {
        _file = "nixpkgs.config";
        config = config1;
      })
    ];
  };

  config = lib.showWarnings configEval.config.warnings configEval.config;
  nixpkgsFun = newArgs: import ./. (args // newArgs);

  allPackages = newArgs: import "${lib.expidus.channels.nixpkgs}/pkgs/top-level/stage.nix" ({
    inherit lib nixpkgsFun;
  } // newArgs);

  boot = import "${lib.expidus.channels.nixpkgs}/pkgs/stdenv/booter.nix" { inherit lib allPackages; };

  stages = stdenvStages {
    inherit lib localSystem crossSystem config overlays crossOverlays;
  };

  pkgs = boot stages;
in checked pkgs
