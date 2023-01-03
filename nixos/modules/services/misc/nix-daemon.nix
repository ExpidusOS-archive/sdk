{ config, lib, pkgs, ... }:
{
  nix.settings = mkAfter (import "${lib.expidus.channels.sdk}/lib/nix-config.nix");
}
