{ lib, callPackage, clang14Stdenv, targetPlatform, isWASM ? targetPlatform.isWasm }@pkgs:
with lib;
let
  stdenv = clang14Stdenv;
in
fixedPoints.makeExtensible (self: {
  sdk = callPackage ../development/tools/expidus/sdk {};

  neutron = callPackage ../development/libraries/expidus/neutron {
    inherit stdenv isWASM;
  };

  neutron-bootstrap = self.neutron.bootstrap;

  libexpidus = callPackage ../development/libraries/expidus/libexpidus {
    inherit stdenv;
  };

  launcher = callPackage ../os-specific/linux/expidus/launcher {
    inherit stdenv;
  };
} // optionalAttrs (!isWASM) {
  wasm = callPackage ./expidus-packages.nix {
    isWASM = !isWASM;
  };
})
