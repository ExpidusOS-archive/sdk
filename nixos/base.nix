{ system ? builtins.currentSystem or "unknown-system" }:
let
  nixos = import ../lib/channels/nixpkgs.nix;
in import (nixos + "/nixos/") { inherit system; }
