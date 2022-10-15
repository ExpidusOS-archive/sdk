let
  nixos = import ../../lib/nixpkgs.nix;
in import (nixos + "/nixos/lib/from-env.nix")
