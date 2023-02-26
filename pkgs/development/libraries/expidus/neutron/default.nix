{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "1ff28a59cbab7c699a414e7cdb29ead5e367774b";
  sha256 = "sha256-XosSYwsnVGsJgGThvuSZ6s9o2WMT8zPIrzfT4vTLDQM=";
  inherit isWASM;
}
