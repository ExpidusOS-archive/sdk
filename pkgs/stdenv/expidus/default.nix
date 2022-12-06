{ lib, clangStdenv, expidus-sdk, clang, zsh, vala }:
clangStdenv.override (old: {
  mkDerivationFromStdenv = import ./make-derivation.nix {
    inherit lib;
    inherit (old) config shell;
  };

  name = "${old.name}-expidus";
})
