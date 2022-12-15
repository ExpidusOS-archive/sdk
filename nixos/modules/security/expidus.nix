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
    security = {
      apparmor = {
        enable = mkForce true;
        enableCache = mkForce true;
      };
      pam.yubico = {
        enable = mkForce true;
        id = "42";
      };
      rtkit.enable = mkForce true;
      tpm2.enable = mkForce true;
      polkit.enable = mkForce true;
      protectKernelImage = mkForce true;
    };

    users.groups.proc = {
      gid = config.ids.gids.proc;
    };

    boot.specialFileSystems."/proc".options = mkForce [ "nosuid" "nodev" "noexec" "hidepid=2" "gid=${toString config.ids.gids.proc}" ];
    systemd.services.systemd-logind.serviceConfig.SupplementaryGroups = "proc";

    services = {
      dbus.apparmor = mkForce "required";
      usbguard.enable = mkForce true;
    };
  };
}
