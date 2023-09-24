{
  description = "SDK for ExpidusOS";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
    fallback = true;
  };

  inputs.flake-utils.url = github:numtide/flake-utils;

  inputs.disko = {
    url = github:nix-community/disko;
    flake = false;
  };

  inputs.nixpkgs = {
    url = github:ExpidusOS/nixpkgs;
    flake = false;
  };

  inputs.mobile-nixos = {
    url = github:NixOS/mobile-nixos;
    flake = false;
  };

  outputs = { self, flake-utils, nixpkgs, mobile-nixos, disko }@args:
    let
      channels = (builtins.mapAttrs (name: attrs: attrs.outPath) (builtins.removeAttrs args [ "self" ])) // {
        expidus-sdk = self.outPath;
      };

      importPackage = import ./pkgs/top-level/overlay.nix channels;
      lib = (import ./lib/extend.nix channels).extend (final: prev: {
        expidus = prev.expidus.extend (final: prev: {
          variants = prev.variants // {
            mkMainline = prev.variants.mkMainline (args // {
              modules = (args.modules or []) ++ [
                {
                  system.expidus = {
                    versionSuffix = ".${lib.substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101")}.${self.shortRev or "dirty"}";
                    revision = lib.mkIf (self ? rev) self.rev;
                  };
                }
              ];
            });
          };

          trivial = prev.trivial.extend (f: p: {
            revision = "${self.rev or "diry"}";
          });
        });
      });
    in {
      inherit lib;

      devShells = lib.expidus.system.default.forAllSystems (system: localSystem:
        let
          pkgs = importPackage {
            inherit localSystem;
          };
        in {
          default = pkgs.mkShell {
            name = "expidus-sdk";
            packages = with pkgs; [ gclient-wrapped python3 pkg-config ninja cipd ];
          };
        });

      expidusConfigurations = lib.expidus.system.default.forAllLinux (system:
        let
          pkgs = self.legacyPackages.${system};
        in {
          demo = lib.expidusSystem {
            inherit pkgs;

            modules = [{
              fileSystems = {
                "/" = {
                  device = "/dev/vdb";
                };
                "/boot/efi" = {
                  device = "/dev/vda";
                };
                "/data" = {
                  device = "/dev/vdc";
                  neededForBoot = true;
                };
              };

              boot = {
                initrd = rec {
                  availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "nvme" "ahci" ];
                  kernelModules = availableKernelModules;
                };
                plymouth.enable = true;
                kernelParams = [ "root=/dev/vdb" "console=ttyS0,9600" ];
              };

              networking = {
                useDHCP = false;
                useNetworkd = false;
              };

              security.polkit.extraConfig = ''
                polkit.addRule(function(action, subject) {
                  return polkit.Result.YES;
                });
              '';

              users.users.expidus = {
                password = "expidus";
                isNormalUser = true;
                home = "/home/expidus";
                description = "ExpidusOS Live User";
                group = "wheel";
                extraGroups = [ "video" "input" "tty" "users" "systemd-journal" ];
              };

              programs.genesis.enable = true;
              security.selinux.enable = true;
              security.apparmor.enable = true;
              services.dbus.apparmor = "enabled";
              services.getty.autologinUser = "expidus";
            }];
          };

          prod-mainline = lib.expidusSystem {
            inherit pkgs;

            modules = [{
              fileSystems = {
                "/" = {
                  device = "/dev/disk/by-label/EXPIDUS_ROOT";
                };
                "/data" = {
                  device = "/dev/disk/by-label/EXPIDUS_DATA";
                  neededForBoot = true;
                };
              };

              system.rootfs.options = [ "-L EXPIDUS_ROOT" ];
              system.datafs.options = [ "-L EXPIDUS_DATA" ];

              boot = {
                initrd = rec {
                  availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "nvme" "ahci" ];
                  kernelModules = availableKernelModules;
                };
                plymouth.enable = true;
                kernelParams = [ "root=/dev/disk/by-label/EXPIDUS_ROOT" ];
              };

              networking = {
                useDHCP = false;
                useNetworkd = false;
              };

              security.selinux.enable = true;
              security.apparmor.enable = true;
              services.dbus.apparmor = "enabled";
              programs.genesis.enable = true;
            }];
          };
        });

      legacyPackages = lib.expidus.system.default.forAllSystems (system: localSystem: importPackage {
        inherit localSystem;
      });

      packages = lib.expidus.system.default.forAllSystems (system: localSystem:
        with lib;
        let
          pkgs = importPackage {
            inherit localSystem;
          };
          filterPkgs = filterAttrs (name: pkg: isAttrs pkg && hasAttr "outPath" pkg);
        in filterPkgs pkgs.expidus);
    };
}
