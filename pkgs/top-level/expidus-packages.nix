{ callPackage }:
rec {
  sdk = callPackage ../development/misc/expidus/sdk/default.nix {};
  buildPackage = callPackage ../build-support/build-expidus-package/default.nix {};
  runtime = callPackage ../development/libraries/expidus/runtime/default.nix {};

  runtime-example = buildPackage {
    pname = "expidus-runtime-example";
    inherit (runtime) version;
    src = "${runtime.src}/example";
    vendorSha256 = "sha256-FxJmIoycLUQPlR2qV9vue2NKq3eNW6Tq4awSGqbwsis=";
  };
}
