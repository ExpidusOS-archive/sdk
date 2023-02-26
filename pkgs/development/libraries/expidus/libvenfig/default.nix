{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "608da0047791169dde896704e90dddceb5fb5a97";
  sha256 = "sha256-j/uD+kyyAL27TCezxyunzR0blBl3BVgMu3xbDMdQtNE=";
}
