{ lib, callPackage }:
with lib;
let
  config = {
    debug = "sha256-rwLH6yBd/h4UNijAs4w2UF6rMJnRv2qylzyRAqAa4Cc=";
    profile = "sha256-XENIl+Hv+xg6b3C3Wo43j0rf7vGYzSf4wl1+wKuO2Gw=";
    release = fakeHash;
    jit_release = fakeHash;
  };
  mkPackage = callPackage ./package.nix {};
in builtins.mapAttrs (runtimeMode: sha256: mkPackage { inherit runtimeMode sha256; }) config
