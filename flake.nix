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

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-22.11;
    flake = false;
  };

  inputs.mobile-nixos = {
    url = github:NixOS/mobile-nixos;
    flake = false;
  };

  outputs = { self, flake-utils, home-manager, nixpkgs, mobile-nixos, disko }@args:
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

      expidusConfigurations.x86_64-linux.demo = lib.expidusSystem {
        pkgs = self.legacyPackages.x86_64-linux;

        modules = [({ pkgs, ... }: {
          fileSystems = {
            "/" = { device = "/dev/vda"; };
            "/data" = {
              device = "/dev/vdb";
              neededForBoot = true;
            };
          };

          boot = {
            initrd = rec {
              availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "nvme" "ahci" ];
              kernelModules = availableKernelModules;
            };
            plymouth.enable = true;
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
          services.getty.autologinUser = "expidus";
        })];
      };

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
