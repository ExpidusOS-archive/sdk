{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "5a63d0f419ae47dcbc7469a0ed972979a19b3cd1";
  sha256 = "sha256-4eKGq+zQK7hBmX0tI9DDlIZQzXyU1iGP/hUPrp63Ax8=";
  inherit isWASM;
}
