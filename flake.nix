{
  description = "SDK for ExpidusOS";

  outputs = { self }@inputs:
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

      sdk-extra = lib.expidus.system.forAllLinux (system:
        with lib;
        with release-lib;
        let
          pkgs = import ./pkgs/top-level/default.nix {
            system = lib.expidus.system.current;
            crossSystem = { inherit system; };
          };

          makeIso = type:
            with pkgs;
            (import ./nixos/lib/eval-config.nix {
              inherit system pkgs;
              modules = [({
                isoImage.isoBaseName = "expidus-${type}";
              }) ./nixos/modules/installer/cd-dvd/installation-cd-${type}.nix];
            }).config.system.build.isoImage;
        in {
          channel = import ./nixos/lib/make-channel.nix {
            inherit pkgs;
            nixpkgs = { revCount = 130979; shortRev = "gfedcba"; } // self;
            inherit (lib.expidus.trivial) version versionSuffix;
          };

          iso-minimal = makeIso "minimal";
          iso-plasma5 = makeIso "graphical-calamares-plasma5";
          iso-gnome = makeIso "graphical-calamares-gnome";
          iso-genesis = makeIso "graphical-calamares-genesis";
        });
    in sdk-flake // ({
      inherit lib self;
      libExpidus = lib.expidus;
      legacyPackages = lib.expidus.system.forAll (system: import ./. { inherit system; });

      hydraJobs = sdk-flake.hydraJobs // (lib.genAttrs [ "channel" "iso-minimal" "iso-plasma5" "iso-gnome" "iso-genesis" ] (name:
        lib.expidus.system.forAllLinux (system: lib.hydraJob sdk-extra.${system}.${name})));

      packages = sdk-flake.packages // sdk-extra;
    });
}
