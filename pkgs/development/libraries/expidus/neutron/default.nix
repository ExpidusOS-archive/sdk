{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "0e9efe62e641813e439d01a4337e574cbd07a470";
  sha256 = "sha256-f94INnlUmcZnXnTGCw5R31A1+mCY9M9purk+IcFpffI=";
  inherit isWASM;
}
