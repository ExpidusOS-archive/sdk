let
  nixos = import ../../lib/channels/nixpkgs.nix;
in import (nixos + "/nixos/lib/from-env.nix")
