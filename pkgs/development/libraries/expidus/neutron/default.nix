{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "c0c6ed1fff4a8fd43a294572c2c36d2e91d1da21";
  sha256 = "sha256-z4MBTrEGSH7tfsJAANw++J8HEAC9efSH++YTVmhtyfM=";
  inherit isWASM;
}
