{ config, lib, pkgs, ... }:
with lib;
{
  options.services.xserver = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable the X server.
      '';
    };
  };
}
