args:
let
  base = import ./pkgs-base.nix args;
  extend = import ./pkgs-extend.nix args;
in base // extend
