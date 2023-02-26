{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "2f76e95d042c3be5f7302ffbad03391662bd6270";
  sha256 = "sha256-Avbni2sh6t/cUHipbOAwLL+u4SyJzv4QPm6AlluuZH0=";
}
