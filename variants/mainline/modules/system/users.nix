{ config, pkgs, lib, ... }:
{
  config.environment.etc = {
    "passwd".text = ''
      root:x:0:0:System administrator:/root:/run/current-system/sw/bin/bash
    '';
    "group".text = ''
      root:x:0:
    '';
    "shadow".text = ''
      root:!:1::::::
    '';
  };
}
