{ nixpkgsPath ? import ../../lib/channels/nixpkgs.nix }:
import (nixpkgsPath + "/nixos/lib/from-env.nix")
