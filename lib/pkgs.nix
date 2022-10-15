{ system ? builtins.currentSystem or "unknown-system" }:
let
  base = import ./pkgs-base.nix { inherit system; };
  extend = import ./pkgs-extend.nix { inherit system; };
in base // extend
