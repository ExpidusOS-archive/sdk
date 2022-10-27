let
  nixpkgs = ../../lib/nixpkgs.nix;
in import (nixpkgs + "/pkgs/pkgs-lib/default.nix")
