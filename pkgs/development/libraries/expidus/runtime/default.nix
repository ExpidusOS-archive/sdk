{ lib, callPackage }:
with lib;
let
  pkg = callPackage ./package.nix {};
in pkg {
  rev = "86cdb8ce557b4bf7810a60294b2cb4ed92c2a8fd";
  sha256 = "sha256-IRq9C2vgsO/IyxqUod95LOL1mJGJO3F2PKhub4aCFO4=";
}
