{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "94eba3f78df88f04a793cdee8e9c54ca7e2b87ef";
  sha256 = "sha256-boOAT/BLf1s+RRybzH+qSbgxg34Wc1CJBiKJCDtJxJo=";
}
