{ config, lib, options, ... }:
with lib;
let
  cfg = config.security.expidus;
in
{
  options = {
    security.expidus = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the ExpidusOS System Security profiles";
      };
    };
  };

  config = mkIf cfg.enable {
    security.apparmor = {
      enable = mkForce true;
      enableCache = mkForce true;
    };

    services.dbus.apparmor = mkForce "enabled";
  };
}
