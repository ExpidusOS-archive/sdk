{ lib, callPackage, clang14Stdenv, targetPlatform, zigpkgs }@pkgs:
with lib;
let
  stdenv = clang14Stdenv;
  zig = zigpkgs.master;
in
fixedPoints.makeExtensible (self: {
  sdk = callPackage ../development/tools/expidus/sdk {};

  neutron = callPackage ../development/libraries/expidus/neutron {
    inherit stdenv zig;
  };
})
