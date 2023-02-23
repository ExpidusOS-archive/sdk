{ callPackage }:
let
  mkPackage = callPackage ./package.nix {};
in mkPackage {
  rev = "101e674e914d2fc8bf235039b34312244ac22b6c";
  sha256 = "sha256-nT2qRe9NoRYzu3vdYO11Rta+OjYjIAMsDTe0zBaRtv4=";
}
