{ nixpkgs, home-manager, flake-utils, ... }@channels:
(import "${nixpkgs}/lib").extend (import ./overlay.nix channels)
