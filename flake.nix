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
    in sdk-flake // ({
      inherit lib self;
      libExpidus = lib.expidus;
      legacyPackages = lib.expidus.system.forAll (system: import ./. { inherit system; });

      packages = lib.expidus.system.forAll (system:
        with release-lib;
        with lib;
        let
          flake-base = if builtins.hasAttr system sdk-flake.packages then sdk-flake.packages.${system} else {};

          pkgs = import ./pkgs/top-level/default.nix {
            system = lib.expidus.system.current;
            crossSystem = { inherit system; };
          };

          makeIso = { module, type, ... }:
            with pkgs;
            hydraJob ((import ./nixos/lib/eval-config.nix {
              inherit system pkgs;
              modules = [({
                isoImage.isoBaseName = "expidus-${type}";
              }) module];
            }).config.system.build.isoImage);
        in (flake-base // {
          channel = import ./nixos/lib/make-channel.nix {
            inherit pkgs;
            nixpkgs = self;
            inherit (lib.expidus.trivial) version versionSuffix;
          };

          iso-minimal = makeIso {
            module = ./nixos/modules/installer/cd-dvd/installation-cd-minimal.nix;
            type = "minimal";
          };

          iso-plasma5 = makeIso {
            module = ./nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix;
            type = "plasma5";
          };

          iso-gnome = makeIso {
            module = ./nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix;
            type = "gnome";
          };

          iso-genesis = makeIso {
            module = ./nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-genesis.nix;
            type = "genesis";
          };
        }));
    });
}
