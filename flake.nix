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
    url = github:ExpidusOS/nixpkgs/nixos-22.11;
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
      lib = import ./lib/overlay.nix channels;
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
        in (filterPkgs pkgs.expidus)
          // (renameAttrs (name: value: value.pname) pkgs.flutter-engine.runtimeModes)
          // {
            inherit (pkgs) flutter-engine;
          });
    };
}
