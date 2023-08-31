{ nixpkgs, ... }:
rec {
  nixpkgsUtils = { lib, config, pkgs, ... }: import "${nixpkgs}/nixos/lib/utils.nix" { inherit lib config pkgs; };
  nixpkgsImport = module: { config, lib, pkgs, ... }@args:
    let
      utils = nixpkgsUtils args;
      _module = import module (args // {
        inherit utils;
      });
    in _module // {
      _file = module;
      key = module;
    };
}
