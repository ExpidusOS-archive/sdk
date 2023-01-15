{ callPackage }:
rec {
  buildPackage = callPackage ../build-support/build-expidus-package/default.nix {};
  runtime = callPackage ../development/libraries/expidus/runtime/default.nix {};
}
