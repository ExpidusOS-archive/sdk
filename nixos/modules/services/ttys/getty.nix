{ config, lib, pkgs, options, ... }@args:
with lib;
let
  base = (import (expidus.nixpkgsPath + "/nixos/modules/services/ttys/getty.nix")) args;
in base // {
  config.services.getty.greetingLine = mkDefault ''<<< Welcome to ExpidusOS ${expidus.trivial.version} (\m) - \l >>>'';
}
