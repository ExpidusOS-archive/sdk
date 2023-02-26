{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "16936f3cf4cc2108973c898b845c9b3bf23c26a5";
  sha256 = "sha256-tLuZxXFsemolHGKw4Xxqcnss3obJcdbt90Qy1UWQ7Cg=";
}
