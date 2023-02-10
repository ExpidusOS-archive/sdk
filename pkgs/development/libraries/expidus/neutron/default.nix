{ callPackage, stdenv }:
callPackage ./package.nix {
  inherit stdenv;
} {
  rev = "7cda7c85af49accca9625f5c8f5297d2c0e243e3";
  sha256 = "sha256-8OUNZ1BPBou8v69RzZ8UO/frfXy2LDDOFaf4iq/NFdA=";
}
