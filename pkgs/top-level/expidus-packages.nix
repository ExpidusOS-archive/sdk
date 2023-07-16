{ lib, callPackage }@pkgs:
with lib;
fixedPoints.makeExtensible (self: {
  sdk = callPackage ../development/tools/expidus/sdk {};
  gokai = callPackage ../development/libraries/expidus/gokai {};
  genesis-shell = callPackage ../desktops/genesis-shell {};
})
