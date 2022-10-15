args:
let
  lib = import ./lib/default.nix;
  pkgs = import ./lib/pkgs.nix args;
in pkgs // { inherit lib; }
