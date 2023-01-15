{ callPackage }:
rec {
  buildPackage = callPackage ../../build-support/build-expidus-package/default.nix {};
  runtimes = callPackage ../../development/libraries/expidus/runtimes/default.nix {};
}
