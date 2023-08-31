{ lib, ... }:
with import ./utils.nix lib.expidus.channels;
let
  inherit (lib.expidus.channels) nixpkgs;
in
{
  disabledModules = [
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/xterm.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/phosh.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/xfce.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/plasma5.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/lumina.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/lxqt.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/enlightenment.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/gnome.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/retroarch.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/kodi.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/mate.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/pantheon.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/surf-display.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/cde.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/cinnamon.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/budgie.nix"
    "${nixpkgs}/nixos/modules/services/x11/desktop-managers/deepin.nix"
  ];
}
