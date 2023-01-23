{ lib, callPackage }:
with lib;
let
  mkPackage = callPackage ./package.nix {};
in builtins.listToAttrs (builtins.map (runtimeMode: {
  name = runtimeMode;
  value = mkPackage {
    inherit runtimeMode;
  };
}) [
  "debug"
  "profile"
  "release"
  "jit_release"
])
