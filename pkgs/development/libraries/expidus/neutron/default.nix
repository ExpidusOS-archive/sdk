{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "8f8cae656ae3b4f786d5d983e856e715bdd52011";
  sha256 = "sha256-ZZ3Ge5RRioDe3DrewZNsYWrhyT/vJBcbL+HQp1YcRN0=";
  inherit isWASM;
}
