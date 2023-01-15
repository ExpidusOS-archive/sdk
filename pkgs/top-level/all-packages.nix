pkgs: prev: with pkgs; {
  clang14Stdenv = llvmPackages_14.stdenv;
  expidus = callPackage ./expidus-packages.nix {};
  buildExpidusPackage = expidus.buildPackage;
}
