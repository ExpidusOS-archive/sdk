{ config, lib, ... }:
with lib;
let
  cfg = config.security;
in {
  options.security.lsm = mkOption {
    type = types.listOf types.str;
    default = [];
    description = mdDoc "List of Linux Security Modules to enable";
  };

  config = {
    boot.kernelPatches = mkIf (builtins.length cfg.lsm > 0) [{
      name = "linux-lsm";
      patch = null;
      extraStructuredConfig.LSM = lib.kernel.freeform (builtins.concatStringsSep "," cfg.lsm);
    }];

    security.lsm = mkIf cfg.apparmor.enable [ "apparmor" ];
  };
}
