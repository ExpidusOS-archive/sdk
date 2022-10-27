{ nixpkgsPath, ... }:
args: import (nixpkgsPath + "/pkgs/pkgs-lib/default.nix") args
