{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "850ad2159499ab15ae3bb986e8bc29dd53c64d47";
  sha256 = "sha256-+P2hoHApoORZIm0aieciHzlJgNz3GvpBjC0vCGTY+r4=";
  inherit isWASM;
}
