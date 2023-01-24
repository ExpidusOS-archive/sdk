pkgs: prev: with pkgs; {
  clang14Stdenv = llvmPackages_14.stdenv;
  buildExpidusPackage = expidus.buildPackage;

  expidus = callPackage ./expidus-packages.nix {};
}
