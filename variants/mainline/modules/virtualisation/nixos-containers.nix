{ config, lib, pkgs, ... }:
with lib;
{
  options.boot.isContainer = mkOption {
    type = types.bool;
    default = false;
    description = lib.mdDoc ''
      Whether this ExpidusOS machine is a lightweight container running
      in another ExpidusOS system.
    '';
  };
}
