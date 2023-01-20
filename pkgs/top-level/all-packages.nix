pkgs: prev: with pkgs; {
  depot_tools = callPackage ../development/tools/depot_tools {};
  cipd = callPackage ../development/tools/cipd {};
  gclient-wrapped = callPackage ../development/tools/gclient-wrapped {};
  flutter-engine = callPackage ../development/misc/flutter-engine {};

  clang14Stdenv = llvmPackages_14.stdenv;
  buildExpidusPackage = expidus.buildPackage;

  expidus = callPackage ./expidus-packages.nix {};
}
