{ callPackage }:
rec {
  buildPackage = callPackage ../build-support/build-expidus-package/default.nix {};
  runtime = callPackage ../development/libraries/expidus/runtime/default.nix {};

  runtime-example = buildPackage {
    pname = "expidus-runtime-example";
    inherit (runtime) version;
    src = "${runtime.src}/example";
    vendorSha256 = "sha256-V0TV6oTkZ/DMFiE7fifHOQ0Vm68J9Dw6D2KEdixsH9E=";
  };
}
