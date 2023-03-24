{ callPackage, stdenv, zig }:
callPackage ./package.nix {
  inherit stdenv zig;
} {
  rev = "bb344783dd9e7ba8621745c9298074a8caeabd2f";
  sha256 = "sha256-kS2JnQ2H0gdP9UUrBfpFQmTdIYPFa++qf+mNuzKsm8c=";
}
