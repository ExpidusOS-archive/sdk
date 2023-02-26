{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "4e9828fec1d253480e9e47c603aa9384c0ad26bb";
  sha256 = "sha256-mdfRHvrH0ng/8mKP8WQYKixXMOQSVNMoTs0X7EZRhRQ=";
  inherit isWASM;
}
