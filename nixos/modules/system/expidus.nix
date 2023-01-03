{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.expidus;
  opts = options.expidus;
in {
  options.expidus = {
    binfmt = mkEnableOption "Enable the binfmt registry" // {
      default = true;
    };
    fs = {
      enable = mkEnableOption "Enable the ExpidusOS specific filesystem configuration" // {
        default = true;
      };
      drive = mkOption {
        type = types.str;
        default = "";
        description = ''
          /dev/ drive path to use for the boot drive.
        '';
      };
    };
  };

  config = mkMerge [
    {
      boot.plymouth.enable = mkDefault true;

      services.hercules-ci-agent.settings.labels.expidus =
        let
          mkIfNotNull = x: mkIf (x != null) x;
        in {
          configurationRevision = mkIfNotNull config.system.configurationRevision;
          inherit (config.system.expidus) release codeName tags;
          label = mkIfNotNull config.system.expidus.label;
          systemName = mkIfNotNull config.system.name;
        };

      qt5 = {
        style = mkForce "adwaita-dark";
        platformTheme = mkForce "gtk2";
      };

      services.upower = {
        enable = mkDefault true;
        criticalPowerAction = mkDefault "PowerOff";
        percentageLow = mkDefault 20;
        percentageCritical = mkDefault 10;
        percentageAction = mkDefault 5;
      };

      services.logind = {
        lidSwitch = mkDefault "hybrid-sleep";
        lidSwitchDocked = mkDefault "lock";
        lidSwitchExternalPower = mkDefault "lock";
      };
    }
    (mkIf cfg.binfmt {
      boot.binfmt.emulatedSystems = lib.lists.subtractLists lib.platforms.cygwin (lib.filter (sys: sys != pkgs.system) (lib.expidus.system.supported ++ [
        "i686-windows"
        "x86_64-windows"
      ]));
    })
    /*(mkIf cfg.fs.enable {
      assertions = [{
        assertion = cfg.fs.drive != "" && cfg.fs.drive != null;
        message = "Filesystem drive path cannot be empty";
      }];

      disko.devices = {
        disk.${cfg.fs.drive} = {
          device = "/dev/${cfg.fs.drive}";
          type = "disk";
          content = {
            type = "table";
            format = if config.boot.loader.efi.enable then "gpt" else "msdos";
            partitions = [
              {
                type = "partition";
                name = "BOOT";
                start = "1MiB";
                end = "100MiB";
                bootable = true;
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = config.boot.loader.efi.efiSysMountPoint;
                };
              }
              ({
                type = "partition";
                name = "ROOTFS";
                start = "100MiB";
                end = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  content = {
                    type = "lvm_pv";
                    vg = config.networking.hostName;
                  };
                };
              } // lib.optionalAttrs config.boot.loader.efi.enable {
                part-type = "primary";
                bootable = true;
              })
            ];
          };
        };
        lvm_vg."${config.networking.hostName}" = {
          type = "lvm_vg";
          lvs = {
            zpool = {
              type = "lvm_lv";
              size = "100%";
              content = {
                type = "zfs";
                pool = config.networking.hostName;
              };
            };
          };
        };
        zpool."${config.networking.hostName}" = {
          type = "zpool";
          rootFsOptions = {
            compression = "lz4";
            "com.sun:auto-snapshot" = "false";
          };
          mountpoint = "/";

          datasets = {
            root = {
              zfs_type = "filesystem";
              mountpoint = "/";
              options."com.sun:auto-snapshot" = "true";
            };
            "root/nix" = {
              zfs_type = "filesystem";
              mountpoint = "/nix";
              options."com.sun:auto-snapshot" = "false";
            };
          } //
            (let
              filteredUsers = builtins.attrValues (lib.filterAttrs (name: user: user.isNormalUser || name == "root") config.users.users);
              users = builtins.map (user: {
                name = "root/userdata/${user.name}";
                value = {
                  zfs_type = "filesystem";
                  mountpoint = user.home;
                  options."com.sun:auto-snapshot" = "true";
                };
              }) filteredUsers;
            in builtins.listToAttrs users);
        };
      };
    })*/
  ];
}
