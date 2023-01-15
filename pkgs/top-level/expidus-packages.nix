{ callPackage }:
rec {
  buildPackage = callPackage ../build-support/build-expidus-package/default.nix {};
  runtime = callPackage ../development/libraries/expidus/runtime/default.nix {};

  runtime-example = buildPackage {
    pname = "expidus-runtime-example";
    inherit (runtime) version;
    src = "${runtime}/example";
    vendorSha256 = "sha256-C+IcHfFtDo1Owvx06dIIXy6RRz7njZ+ZIB/uCPZ2Ekw=";
  };
}
