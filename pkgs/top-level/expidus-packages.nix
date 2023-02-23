{ lib, callPackage, clang14Stdenv, targetPlatform, isWASM ? targetPlatform.isWasm }@pkgs:
with lib;
let
  stdenv = clang14Stdenv;
in
fixedPoints.makeExtensible (self: {
  sdk = callPackage ../development/tools/expidus/sdk {};
  launcher = callPackage ../os-specific/linux/expidus/launcher {};

  neutron = callPackage ../development/libraries/expidus/neutron {
    inherit stdenv isWASM;
  };

  neutron-bootstrap = self.neutron.bootstrap;
} // optionalAttrs (!isWASM) {
  wasm = callPackage ./expidus-packages.nix {
    isWASM = !isWASM;
  };
})
