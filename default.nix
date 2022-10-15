args:
let
  lib = import ./lib;
  pkgs = import ./pkgs args;
in pkgs // { inherit lib; }
