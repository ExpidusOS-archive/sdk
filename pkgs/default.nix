args:
import ./base.nix ({
  overlays = [
    (self: super:
      let
        flake-compat = import (fetchTarball {
          url = "https://github.com/edolstra/flake-compat/archive/99f1c2157fba4bfe6211a321fd0ee43199025dbf.tar.gz";
          sha256 = "0x2jn3vrawwv9xp15674wjz9pixwjyj3j771izayl962zziivbx2";
        });
        defaultNix = src: (flake-compat {
          inherit src;
          inherit (self) system;
        }).defaultNix;
      in {
        gtk-layer-shell = self.callPackage ./development/libraries/gtk-layer-shell/default.nix {};

        libadwaita = self.libadwaita.overrideAttrs (old: {
          doCheck = self.stdenv.isLinux;
          buildInputs = old.buildInputs ++ self.lib.optionals self.stdenv.isDarwin (with self.darwin.apple_sdk.frameworks; [
            AppKit Foundation
          ]);
          meta.platforms = self.lib.platforms.unix;
        });

        vte = self.vte.overrideAttrs (old: {
          mesonFlags = old.mesonFlags ++ [ "-D_b_symbolic_functions=false" ];
          meta.broken = false;
        });

        expidus-sdk = (defaultNix ../.).packages.${self.system}.default;

        cssparser = self.callPackage ./development/libraries/cssparser/default.nix {};
        gxml = self.callPackage ./development/libraries/gxml/default.nix {};
        vadi = self.callPackage ./development/libraries/vadi/default.nix {};
        ntk = self.callPackage ./development/libraries/ntk/default.nix {};
        libdevident = self.callPackage ./development/libraries/libdevident/default.nix {};
        libtokyo = self.callPackage ./development/libraries/libtokyo/default.nix {};
        genesis-shell = self.callPackage ./desktops/genesis-shell/default.nix {};
        expidus-terminal = self.callPackage ./applications/terminal-emulators/expidus-terminal/default.nix {};
      })
  ];
} // args)
