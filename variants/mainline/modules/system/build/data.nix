{ config, lib, pkgs, ... }:
with lib;
let
  inherit (config.system) vendorConfig;

  toplevel = pkgs.runCommand "expidus-datafs" {
    dirs = [
      "config"
      "pkgs"
      "users"
      "var/cache"
      "var/db"
      "var/lib"
      "var/log"
    ] ++ optionals vendorConfig.System.nix_daemon [
      "nix/var/log"
      "nix/var/nix"
    ] ++ optional vendorConfig.System.nix_store "nix/store";
  } ''
    mkdir -p $out

    for dir in $dirs; do
      mkdir -p $out/$dir
    done

    ${optionalString vendorConfig.VendorConfig.datafs ''
      touch $out/data/vendor.config
    ''}
  '';
in
{
  system.build.datafs = toplevel;
}
