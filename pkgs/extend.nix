{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  ...
}@args:
let
  pkgs = import ./base.nix args;
  flake-compat = import (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/99f1c2157fba4bfe6211a321fd0ee43199025dbf.tar.gz";
    sha256 = "0x2jn3vrawwv9xp15674wjz9pixwjyj3j771izayl962zziivbx2";
  });
  defaultNix = src: (flake-compat {
    inherit src system;
  }).defaultNix;
in
with pkgs;
rec {
  gtk-layer-shell = pkgs.callPackage ./development/libraries/gtk-layer-shell/default.nix {};

  libadwaita = pkgs.libadwaita.overrideAttrs (old: {
    doCheck = pkgs.stdenv.isLinux;
    buildInputs = old.buildInputs ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [
      AppKit Foundation
    ]);
    meta.platforms = pkgs.lib.platforms.unix;
  });

  vte = pkgs.vte.overrideAttrs (old: {
    mesonFlags = old.mesonFlags ++ [ "-D_b_symbolic_functions=false" ];
    meta.broken = false;
  });

  expidus-sdk = (defaultNix ../.).packages.${system}.default;

  cssparser = pkgs.callPackage ./development/libraries/cssparser/default.nix {};
  gxml = pkgs.callPackage ./development/libraries/gxml/default.nix {};
  vadi = pkgs.callPackage ./development/libraries/vadi/default.nix {};
  ntk = pkgs.callPackage ./development/libraries/ntk/default.nix { inherit cssparser; };
  libdevident = pkgs.callPackage ./development/libraries/libdevident/default.nix { inherit gxml vadi; };
  libtokyo = pkgs.callPackage ./development/libraries/libtokyo/default.nix { inherit vadi ntk libadwaita; };
  genesis-shell = pkgs.callPackage ./desktops/genesis-shell/default.nix { inherit vadi libtokyo libdevident gtk-layer-shell; };
  expidus-terminal = pkgs.callPackage ./applications/terminal-emulators/expidus-terminal/default.nix { inherit libtokyo vte; };
}
