{ lib, ... }:
{
  config = {
    boot.tmp.useTmpfs = lib.mkForce true;

    system.activationScripts.fonts = ''
      mkdir -p /usr/share
      ln -sf /run/current-system/sw/share/X11/fonts/ /usr/share/fonts
    '';
  };
}
