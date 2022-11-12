{ nixpkgs ? import ../../lib/channels/nixpkgs.nix }:
import (nixpkgs + "/nixos/lib/from-env.nix")
