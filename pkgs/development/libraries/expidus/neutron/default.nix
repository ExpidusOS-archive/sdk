{ callPackage, stdenv }:
callPackage ./package.nix {
  inherit stdenv;
} {
  rev = "321500675d638514da3409edbd1859db0017b72d";
  sha256 = "sha256-6nH42MfR6Sq1Lryi6CNXzRHmNPiTOBp1Ub9NihvCo/w=";
}
