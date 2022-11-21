{ lib, config }:
pkgs: super:
let
  callPackage = path: attrs: (pkgs.lib.callPackageWith pkgs) path attrs;
  firefox-packages = callPackage ../applications/networking/browsers/firefox/packages.nix {};
in
with pkgs;
rec {
  wrapFirefox = pkgs.callPackage ../applications/networking/browsers/firefox/wrapper.nix {};
  firefox = wrapFirefox firefox-packages.firefox {};
  firefox-esr = firefox-esr-102;
  firefox-esr-102 = wrapFirefox firefox-packages.firefox-esr-102 {};

  nixos-install-tools = callPackage ../tools/nix/nixos-install-tools/default.nix { inherit (lib.expidus) channels; };
  gtk-layer-shell = pkgs.callPackage ../development/libraries/gtk-layer-shell/default.nix {};

  expidus-sdk = callPackage ../development/tools/expidus-sdk/default.nix {};

  cssparser = pkgs.callPackage ../development/libraries/cssparser/default.nix {};
  gxml = pkgs.callPackage ../development/libraries/gxml/default.nix {};
  vadi = pkgs.callPackage ../development/libraries/vadi/default.nix {};

  ntk = callPackage ../development/libraries/ntk/default.nix {};
  libdevident = callPackage ../development/libraries/libdevident/default.nix {};
  libtokyo = callPackage ../development/libraries/libtokyo/default.nix {};
  genesis-shell = callPackage ../desktops/genesis-shell/default.nix {};
  expidus-terminal = callPackage ../applications/terminal-emulators/expidus-terminal/default.nix {};
}
