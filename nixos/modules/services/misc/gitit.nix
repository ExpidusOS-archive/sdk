{ config, lib, pkgs, options, ... }@args:
with lib;
let
  base = import (lib.expidus.nixpkgsPath + "/nixos/modules/services/misc/gitit.nix") args;
in {
  options.services.gitit = base.options.services.gitit // {
    haskellPackages = mkOption {
      default = pkgs.haskellPackages;
      defaultText = literalExpression "pkgs.haskellPackages";
      example = literalExpression "pkgs.haskell.packages.ghc784";
      description = "haskellPackages used to build gitit and plugins.";
    };
  };
  inherit (base) config;
}
