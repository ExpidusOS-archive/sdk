{ callPackage }:
rec {
  buildPackage = callPackage ../build-support/build-expidus-package/default.nix {};
  runtime = callPackage ../development/libraries/expidus/runtime/default.nix {};

  runtime-example = buildPackage {
    pname = "expidus-runtime-example";
    inherit (runtime) version;
    src = "${runtime}/example";
  };
}
