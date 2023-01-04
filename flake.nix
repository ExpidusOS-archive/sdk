{
  description = "SDK for ExpidusOS";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
  };

  inputs.utils.url = github:numtide/flake-utils;

  inputs.disko = {
    url = github:RossComputerGuy/disko/fix/option-descriptions;
    flake = false;
  };

  inputs.nixpkgs = {
    url = github:NixOS/nixpkgs/nixos-22.11;
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

  outputs = { self, utils, home-manager, nixpkgs, mobile-nixos, disko }:
    let
      lib = (import ./lib/overlay.nix {
        home-manager = home-manager.outPath;
        nixpkgs = nixpkgs.outPath;
        mobile-nixos = mobile-nixos.outPath;
        disko = disko.outPath;
        sdk = self.outPath;
      }).extend (final: prev: {
        nixos = import ./nixos/lib { lib = final; };
        nixosSystem = args:
          import ./nixos/lib/eval-config.nix (args // {
            lib = args.lib or lib;
            pkgs = args.pkgs or self.legacyPackages.${args.system};
          } //  lib.optionalAttrs (! args ? system) {
            system = null;
          });

        expidus = prev.expidus.extend (f: p: {
          trivial = p.trivial // (p.trivial.makeVersion {
            revision = self.shortRev or "dirty";
          });

          flake = import ./lib/flake.nix { inherit lib; expidus = f; };
        });
      });

      homeManager = (import "${lib.expidus.channels.home-manager}/flake.nix").outputs {
        self = homeManager;
        nixpkgs = self;
        inherit utils;
      };

      diskoFlake = (import "${lib.expidus.channels.disko}/flake.nix").outputs {
        self = diskoFlake;
        nixpkgs = self;
      };

      sdk-flake = lib.expidus.flake.makeOverride { inherit self; name = "expidus-sdk"; };

      release-lib = import "${lib.expidus.channels.nixpkgs}/pkgs/top-level/release-lib.nix" {
        supportedSystems = lib.expidus.system.supported;
        packageSet = import ./.;
      };

      makeIso = pkgs: type:
        with pkgs;
        (import ./nixos/lib/eval-config.nix {
          inherit pkgs;
          inherit (pkgs) system;
          modules = ["${toString ./nixos/modules/installer/cd-dvd}/installation-cd-${type}.nix" ({
            isoImage.isoBaseName = "expidus-${type}";
          })];
        }).config.system.build.isoImage;

      makeSdImage = pkgs: type:
        with pkgs;
        (import ./nixos/lib/eval-config.nix {
          inherit pkgs;
          inherit (pkgs) system;
          modules = ["${toString ./nixos/modules/installer/sd-card}/sd-image-${type}.nix"];
        }).config.system.build.sdImage;

      release-unique = pkgs: {
        installer-raspberry-pi = makeSdImage pkgs.pkgsCross.raspberry-pi "raspberrypi-installer";
        installer-aarch64 = makeSdImage pkgs.pkgsCross.aarch64-multiplatform "aarch64-installer";
      };

      manuals = lib.expidus.system.mapPossible (system: value:
        let
          pkgs = import ./pkgs/top-level/default.nix {
            localSystem = value;
          };

          nixosSystem = if pkgs.targetPlatform.isLinux then
            (import ./nixos/lib/eval-config.nix {
              inherit system pkgs;
              modules = [];
            })
          else null;

          getManual = name: kind: nixosSystem.config.system.build.${name}.${kind};

          getManualSet = name: attr:
            let
              getManual' = getManual attr;
            in {
              "${name}-manual" = getManual' "manualHTML";
              "${name}-manual-html" = getManual' "manualHTML";
              "${name}-manual-epub" = getManual' "manualEpub";
              "${name}-manpages" = getManual' "manpages";
            };
        in {
          pkgs-manual = import ./doc {
            inherit pkgs;
            nixpkgs = self;
          };
        } // lib.optionalAttrs (nixosSystem != null) (getManualSet "nixos" "manual" // getManualSet "expidus" "expidus-manual"));

      release-base = lib.expidus.system.mapPossible (system: value:
        let
          pkgs = import ./pkgs/top-level/default.nix {
            localSystem = value;
          };
          sysconfig = lib.expidus.system.make {
            currentSystem = system;
          };
        in with pkgs;
        with lib; lib.mergeAttrs
          {
            channel = import ./nixos/lib/make-channel.nix {
              inherit pkgs;
              nixpkgs = self;
              inherit (lib.expidus.trivial) version versionSuffix;
            };
          }
          (if (builtins.tryEval grub2_efi).success && sysconfig.isLinux then {
            iso-minimal = makeIso pkgs "minimal";
            iso-plasma5 = makeIso pkgs "graphical-calamares-plasma5";
            iso-gnome = makeIso pkgs "graphical-calamares-gnome";
            iso-genesis = makeIso pkgs "graphical-calamares-genesis";
          } else {})
        );

      release = lib.expidus.system.mapPossible (system: value:
        let
          pkgs = import ./pkgs/top-level/default.nix {
            localSystem = value;
          };
          unique = release-unique pkgs;
          base = release-base.${system} or {};
          manualSets = manuals.${system} or {};
        in base // unique // manualSets);

      forReleaseJobs = lib.genAttrs (lib.lists.unique (lib.lists.flatten (builtins.attrValues (builtins.mapAttrs (name: value: builtins.attrNames value) release))));

      sdk-hydra = forReleaseJobs (name:
        let
          systems = builtins.attrNames (lib.attrsets.filterAttrs (name: has: has == true) (lib.expidus.system.forAllLinux (system:
            let
              set = release.${system} or {};
            in builtins.hasAttr name set)));
          forAllSystems = lib.genAttrs systems;
        in forAllSystems (system: release.${system}.${name}));
    in sdk-flake // ({
      lib = lib.extend (final: prev: {
        inherit (homeManager.lib) hm homeManagerConfiguration;
      });

      libExpidus = lib.expidus;
      legacyPackages = builtins.listToAttrs (builtins.attrValues (sdk-flake.metadata.sysconfig.mapPossible (system: value: {
        name = value.system;
        value = import ./. {
          localSystem = value;
        };
      })));

      darwinModules = {
        inherit (homeManager.darwinModules) home-manager;
      };

      nixosModules = {
        inherit (homeManager.nixosModules) home-manager;
        inherit (diskoFlake.nixosModules) disko;
      };

      hydraJobs = sdk-flake.hydraJobs // sdk-hydra;
      packages = builtins.mapAttrs (system: base:
        let
          releases = release.${system} or {};
          manualSets = manuals.${system} or {};
          home-manager = if builtins.hasAttr system homeManager.packages then homeManager.packages.${system}.default else null;
          disko = if builtins.hasAttr system diskoFlake.packages then diskoFlake.packages.${system}.default else null;
        in base // releases // manualSets // (lib.optionalAttrs (home-manager != null) {
          inherit home-manager;
        }) // (lib.optionalAttrs (disko != null) {
          inherit disko;
        })) sdk-flake.packages;
    });
}
