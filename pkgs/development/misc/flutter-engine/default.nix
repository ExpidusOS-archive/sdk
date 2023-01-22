{ lib, callPackage }:
with lib;
let
  config = {
    debug = "sha256-rwLH6yBd/h4UNijAs4w2UF6rMJnRv2qylzyRAqAa4Cc=";
    profile = "sha256-XENIl+Hv+xg6b3C3Wo43j0rf7vGYzSf4wl1+wKuO2Gw=";
    release = "sha256-gpja2/jmWkMpq4BCYTJQwLxVaKy/Z8m/Y2FYv5p0f4A=";
    jit_release = "sha256-5/NYM6dtM4ESE2xO20bom5Jg00AWsD2kNLlJBAyNy5Y=";
  };
  mkPackage = callPackage ./package.nix {};
in builtins.mapAttrs (runtimeMode: sha256: mkPackage { inherit runtimeMode sha256; }) config
