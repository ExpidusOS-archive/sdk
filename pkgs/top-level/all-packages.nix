pkgs: prev: with pkgs; {
  clang14Stdenv = llvmPackages_14.stdenv;
  buildExpidusPackage = expidus.buildPackage;
  fetchFromPubdev = callPackage ../build-support/fetchpubdev {};
  buildDartVendor = callPackage ../build-support/dartvendor {};

  expidus = callPackage ./expidus-packages.nix {};
}
