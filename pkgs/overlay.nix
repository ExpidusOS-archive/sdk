{ nixpkgsPath, sdkPath }:
{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  ...
}@args:
let
  lib = import (sdkPath + "/lib/overlay.nix") nixpkgsPath;

  extend-attrs = {
    inherit lib;
    path = sdkPath;
  };

  pkgs = import (nixpkgsPath + "/default.nix") ({
    overlays = [
      (self: super:
        let
          callPackage = path: attrs: (self.lib.callPackageWith (self // extend-attrs)) path attrs;
        in (extend-attrs // {
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

          expidus-sdk = callPackage ./development/tools/expidus-sdk/default.nix {};

          cssparser = self.callPackage ./development/libraries/cssparser/default.nix {};
          gxml = self.callPackage ./development/libraries/gxml/default.nix {};
          vadi = self.callPackage ./development/libraries/vadi/default.nix {};

          ntk = callPackage ./development/libraries/ntk/default.nix {};
          libdevident = callPackage ./development/libraries/libdevident/default.nix {};
          libtokyo = callPackage ./development/libraries/libtokyo/default.nix {};
          genesis-shell = callPackage ./desktops/genesis-shell/default.nix {};
          expidus-terminal = callPackage ./applications/terminal-emulators/expidus-terminal/default.nix {};
        }))
    ];
  } // args);
in (pkgs // extend-attrs)
