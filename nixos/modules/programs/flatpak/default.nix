{ config, lib, options, ... }:
with lib;
let
  cfg = config.flatpak;
in {
  options.flatpak = {
    runtimes = mkOption {
      type = types.attrsOf expidus.types.flatpak.runtime;
      default = {};
      description = ''
        A set of runtimes to install
      '';
    };
    applications = mkOption {
      type = types.attrsOf expidus.types.flatpak.application;
      default = {};
      description = ''
        A set of applications to install
      '';
    };
  };
}
