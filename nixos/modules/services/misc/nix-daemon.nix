{ config, lib, pkgs, ... }:
with lib;
{
  nix.settings = mapAttrs (name: value: mkAfter value) (import "${lib.expidus.channels.sdk}/lib/nix-config.nix");
}
