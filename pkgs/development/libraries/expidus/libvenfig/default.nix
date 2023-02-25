{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "66012c463a7b39f5dc0f56c6851b315ec56b8b3c";
  sha256 = "sha256-686hVGJ9wpmDscW4sPeQbaVnML5eXbfjd1MxgXOqwMI=";
}
