{ lib, callPackage, stdenvExpidus, expidus-sdk, ... }:
let
  mkBaseShell = callPackage "${lib.expidus.channels.nixpkgs}/pkgs/build-support/mkshell/default.nix" {};
in attrs:
  let
    drv = mkBaseShell.override {
      stdenv = stdenvExpidus;
    } attrs;
  in drv.overrideAttrs (old: {
    packages = (old.packages or []) ++ [ expidus-sdk ];
    shellHook = ''
      ${old.shellHook}

      source ${expidus-sdk}/etc/profile.d/expidus-sdk.sh
      exec $EXPIDUS_SDK_BINDIR/zsh
    '';
  })
