{ callPackage, stdenv }:
callPackage ./package.nix {
  inherit stdenv;
} {
  rev = "e2a9801967dc20653dc3aff90a1c581f08abfc83";
  sha256 = "sha256-X5AwSmQSzYD9Q0gGPcZGQYicZ3ep2uMQattch0fU8uA=";
}
