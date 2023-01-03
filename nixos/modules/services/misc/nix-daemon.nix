{ config, lib, pkgs, ... }:
with lib;
{
  nix.settings = mkAfter (import "${lib.expidus.channels.sdk}/lib/nix-config.nix");
}
