{ config, lib, pkgs, options, ... }:
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
      pam = {
        yubico = {
          enable = mkForce true;
          id = "42";
        };
        services = mkMerge [
          {
            login.enableAppArmor = true;
          }
          (mkIf config.security.sudo.enable {
            sudo.enableAppArmor = true;
          })
          (mkIf config.services.xserver.displayManager.gdm.enable {
            gdm-launch-environment.enableAppArmor = true;
            gdm-autologin.enableAppArmor = true;
            gdm-password.enableAppArmor = true;
          })
        ];
      };
      rtkit.enable = mkForce true;
      tpm2.enable = mkForce true;
      polkit.enable = mkForce true;
      protectKernelImage = mkForce true;
    };

    users.groups.proc = {
      gid = config.ids.gids.proc;
      members = [ "polkit" ];
    };

    boot.specialFileSystems."/proc".options = mkForce [ "nosuid" "nodev" "noexec" "hidepid=1" "gid=${toString config.ids.gids.proc}" ];
    systemd.services.systemd-logind.serviceConfig.SupplementaryGroups = "proc";

    services = {
      dbus.apparmor = mkForce "enabled";
      usbguard = {
        enable = mkForce true;
        implictPolicyTarget = mkDefault "allow";
      };
    };
  };
}
