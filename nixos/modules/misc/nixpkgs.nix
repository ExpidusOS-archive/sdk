args@{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixpkgs;
  opt = options.nixpkgs;

  defaultPkgs = import ../../../. {
    inherit (cfg) config overlays localSystem crossSystem;
  };

  base = import ((import ../../../lib/nixpkgs.nix) + "/nixos/modules/misc/nixpkgs.nix") (args // {
    pkgs = if opt.pkgs.isDefined then cfg.pkgs.appendOverlays cfg.overlays else defaultPkgs;
  });
in base
