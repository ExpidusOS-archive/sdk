{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.security.selinux;
in {
  options.security.selinux = {
    enable = mkEnableOption (mdDoc "SELinux security");
  };

  config = mkIf cfg.enable {
    boot = {
      kernelPatches = [{
        name = "selinux";
        patch = null;
        extraStructuredConfig = with kernel; {
          SECURITY_SELINUX = yes;
          SECURITY_SELINUX_BOOTPARAM = yes;
          SECURITY_SELINUX_AVC_STATS = yes;
          SECURITY_SELINUX_CHECKREQPROT_VALUE = freeform "0";
        };
      }];
    };

    security.lsm = [ "selinux" ];

    environment.systemPackages = with pkgs; [ policycoreutils ];
    systemd.package = pkgs.systemd.override { withSelinux = true; };
  };
}
