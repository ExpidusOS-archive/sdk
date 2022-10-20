args:
import ./base.nix ({
  overlays = [
    (self: super: {
      gtk-layer-shell = self.callPackage ./development/libraries/gtk-layer-shell/default.nix {};

      libadwaita = super.libadwaita.overrideAttrs (old: {
        doCheck = super.stdenv.isLinux;
        buildInputs = old.buildInputs ++ self.lib.optionals self.stdenv.isDarwin (with self.darwin.apple_sdk.frameworks; [
          AppKit Foundation
        ]);
        meta.platforms = self.lib.platforms.unix;
      });

      vte = super.vte.overrideAttrs (old: {
        mesonFlags = old.mesonFlags ++ [ "-D_b_symbolic_functions=false" ];
        meta.broken = false;
      });

      expidus-sdk = self.callPackage ./development/tools/expidus-sdk/default.nix {};

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
