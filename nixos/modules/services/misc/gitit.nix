args@{ config, lib, pkgs, ... }:
with lib;
let
  base = import ((import ../../../../lib/nixpkgs.nix) + "/nixos/modules/services/misc/gitit.nix") args;
in {
  options.services.gitit = base.options.services.gitit // {
    haskellPackages = mkOption {
      type = types.functionTo (types.listOf types.package);
      default = pkgs.haskellPackages;
      defaultText = literalExpression "pkgs.haskellPackages";
      example = literalExpression "pkgs.haskell.packages.ghc784";
      description = lib.mdDoc "haskellPackages used to build gitit and plugins.";
    };
  };
  inherit (base) config;
}
