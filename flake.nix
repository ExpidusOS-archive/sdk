{
  description = "SDK for ExpidusOS";

  outputs = { self }:
    let
      lib = (import ./lib).extend (final: prev: {
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

      sdk-flake = lib.expidus.flake.makeOverride { inherit self; name = "expidus-sdk"; };

      release-lib = import "${lib.expidus.channels.nixpkgs}/pkgs/top-level/release-lib.nix" {
        supportedSystems = lib.expidus.system.supported;
        packageSet = import ./.;
      };

      makeIso = system: type:
        let pkgs = import ./pkgs/top-level/default.nix {
          system = lib.expidus.system.current;
          crossSystem = { inherit system; };
        };
        in with pkgs;
        (import ./nixos/lib/eval-config.nix {
          inherit system pkgs;
          modules = ["${toString ./nixos/modules/installer/cd-dvd}/installation-cd-${type}.nix" ({
            isoImage.isoBaseName = "expidus-${type}";
          })];
        }).config.system.build.isoImage;

      makeSdImage = system: type:
        let pkgs = import ./pkgs/top-level/default.nix {
          system = lib.expidus.system.current;
          crossSystem = { inherit system; };
        };
        in with pkgs;
        (import ./nixos/lib/eval-config.nix {
          inherit system pkgs;
          modules = ["${toString ./nixos/modules/installer/sd-card}/sd-image-${type}.nix"];
        }).config.system.build.sdImage;

      release-unique = {
        aarch64-linux = {
          raspberry-pi = makeSdImage "aarch64-linux" "aarch64-installer";
        };
        armv6l-linux = {
          raspberry-pi = makeSdImage "armv6l-linux" "raspberrypi-installer";
        };
      };

      release-base = lib.expidus.system.forAll (system:
        let
          pkgs = import ./pkgs/top-level/default.nix {
            system = lib.expidus.system.current;
            crossSystem = { inherit system; };
          };
          sysconfig = lib.expidus.system.make {
            currentSystem = system;
          };
        in with pkgs;
        with lib; lib.mergeAttrs
          {
            channel = import ./nixos/lib/make-channel.nix {
              pkgs = import ./pkgs/top-level/default.nix {
                system = lib.expidus.system.current;
                crossSystem = { inherit system; };
              };
              nixpkgs = {
                outPath = lib.cleanSource ./.;
                revCount = 130979;
                shortRev = lib.expidus.trivial.revision or "gfedcba";
              };
              inherit (lib.expidus.trivial) version versionSuffix;
            };
          }
          (if (builtins.tryEval grub2_efi).success && sysconfig.isLinux then {
            iso-minimal = makeIso system "minimal";
            iso-plasma5 = makeIso system "graphical-calamares-plasma5";
            iso-gnome = makeIso system "graphical-calamares-gnome";
            iso-genesis = makeIso system "graphical-calamares-genesis";
          } else {})
        );

      release = lib.expidus.system.forAllLinux (system:
        let
          unique = release-unique.${system} or {};
          base = release-base.${system} or {};
        in base // unique);

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
      inherit lib;
      libExpidus = lib.expidus;
      legacyPackages = sdk-flake.metadata.sysconfig.forAllPossible (system: import ./. {
        inherit system;
      });

      hydraJobs = sdk-flake.hydraJobs // sdk-hydra;
      packages = sdk-flake.metadata.sysconfig.forAllPossible (system:
        let
          base = sdk-flake.packages.${system};
          releases = release.${system} or {};
        in base // releases);
    });
}
