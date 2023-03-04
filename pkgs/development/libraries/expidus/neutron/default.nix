{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "6d6558cec22999ce214e8f49813e3b835ac1f897";
  sha256 = "sha256-gllf2ZMdPTgDfUM2yNmESwGl52rFs4jpy1WtN4vUvKQ=";
  inherit isWASM;
}
