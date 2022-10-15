{ system ? builtins.currentSystem or "unknown-system" }:
let
  nixos = import ../lib/nixpkgs.nix;
in import (nixos + "/nixos/") { inherit system; }
