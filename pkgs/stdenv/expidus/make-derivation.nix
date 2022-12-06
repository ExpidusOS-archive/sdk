{ lib, config, shell }:
let
  baseMakeDerivation = import "${lib.expidus.channels.nixpkgs}/pkgs/stdenv/generic/make-derivation.nix" { inherit lib config; };
in stdenv: attrs: baseMakeDerivation stdenv ({
  realBuilder = shell;
} // attrs)
