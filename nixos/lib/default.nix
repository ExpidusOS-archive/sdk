# Source (https://github.com/NixOS/nixpkgs/blob/nixos-22.05/nixos/lib/default.nix)
{ # Optional. Allows an extended `lib` to be used instead of the regular Nixpkgs lib.
  lib ? import ../../lib,

  # Feature flags allow you to opt in to unfinished code. These may change some
  # behavior or disable warnings.
  featureFlags ? {},

  # This file itself is rather new, so we accept unknown parameters to be forward
  # compatible. This is generally not recommended, because typos go undetected.
  ...
}:
let
  seqIf = cond: if cond then builtins.seq else a: b: b;
  # If cond, force `a` before returning any attr
  seqAttrsIf = cond: a: lib.mapAttrs (_: v: seqIf cond a v);

  # The warning is in a top-level let binding so it is only printed once.
  minimalModulesWarning = lib.warn "lib.nixos.evalModules is experimental and subject to change. See nixos/lib/default.nix" null;

  eval-config-minimal = import ./eval-config-minimal.nix { inherit lib; };

  testing-lib = import "${lib.expidus.channels.nixpkgs}/nixos/lib/testing/default.nix" { inherit lib; };
in
/*
  This attribute set appears as lib.nixos in the flake, or can be imported
  using a binding like `nixosLib = import (nixpkgs + "/nixos/lib") { }`.
*/
{
  inherit (seqAttrsIf (!featureFlags?minimalModules) minimalModulesWarning eval-config-minimal)
    evalModules
    ;

  inherit (testing-lib)
    evalTest
    runTest
    ;

}
