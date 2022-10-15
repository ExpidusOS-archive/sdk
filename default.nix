{ system ? builtins.currentSystem or "unknown-system" }:
let
  lib = import ./lib/default.nix;
  pkgs = import ./lib/pkgs.nix { inherit system; };
in pkgs // { lib.expidus = lib; }
