{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "927d025f917c21fea0eaf084ae384700b6e5c324";
  sha256 = "sha256-/HH/rD72vnal84V8nT9AjZMCYdfCGUhDgnzvdx0Tc5U=";
  inherit isWASM;
}
