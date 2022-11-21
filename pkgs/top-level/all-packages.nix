{ lib, config }:
pkgs: super:
let
  callPackage = path: attrs: (pkgs.lib.callPackageWith pkgs) path attrs;
  firefox-packages = callPackage ../applications/networking/browsers/firefox/packages.nix {};
in
with pkgs;
rec {
  nixos = configuration:
    let
      c = import ../../nixos/lib/eval-config.nix {
        inherit (pkgs.stdenv.hostPlatform) system;
        pkgs = pkgs;
        inherit lib;
        modules = [({ lib, ... }: {
          config.nixpkgs.pkgs = lib.mkDefault pkgs;
        })] ++ (if builtins.isList configuration then
          configuration
        else [configuration]);
      };
    in c.config.system.build // c;

  nixosOptionsDoc = attrs:
    (import ../../nixos/lib/make-options-doc)
      ({ inherit lib; pkgs = pkgs; } // attrs);

  nix = super.nix.overrideAttrs (old: {
    doInstallCheck = pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform;
  });

  glib = super.glib.overrideAttrs (old:
    let
      buildDocs = pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform && !pkgs.stdenv.hostPlatform.isStatic;
    in {
      nativeBuildInputs = with pkgs; [
        meson
        ninja
        pkg-config
        perl
        python3
        gettext
        libxslt
        docbook_xsl
      ] ++ lib.optionals buildDocs [
        gtk-doc
        docbook_xml_dtd_45
        libxml2
      ];
    });

  efivar = super.efivar.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (fetchpatch {
        url = "https://github.com/rhboot/efivar/commit/ca48d3964d26f5e3b38d73655f19b1836b16bd2d.patch";
        hash = "sha256-DkNFIK4i7Eypyf2UeK7qHW36N2FSVRJ2rnOVLriWi5c=";
      })
    ];
  });

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
