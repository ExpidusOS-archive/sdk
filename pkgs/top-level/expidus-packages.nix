{ lib, callPackage, clang14Stdenv, emscriptenStdenv, isWASM ? false }@pkgs:
with lib;
let
  stdenv = clang14Stdenv // optionalAttrs (isWASM) {
    inherit (emscriptenStdenv) mkDerivation;
  };
in
fixedPoints.makeExtensible (self: {
  sdk = callPackage ../development/tools/expidus/sdk {};

  neutron = callPackage ../development/libraries/expidus/neutron {
    inherit stdenv;
  };
  neutron-bootstrap = self.neutron.bootstrap;
} // optionalAttrs (!isWASM) {
  wasm = callPackage ./expidus-packages.nix {
    isWASM = !isWASM;
  };
})
