{ lib, config, ... }:
pkgs: super:
with pkgs;
rec {
  inherit lib;
  path = lib.expidus.channels.sdk;

  nix = super.nix.overrideAttrs (old: {
    doInstallCheck = stdenv.hostPlatform == stdenv.buildPlatform;
  });

  ninja = super.ninja.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "NickCao";
      repo = "ninja";
      rev = "92330cc2320cc8aac432d80da12235abcb2bb449";
      sha256 = "G5mIIHET2Wi6RANqAyIiY+APgz7nASYOkNrkjVK14AA=";
    };
  });

  efivar = super.efivar.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (fetchpatch {
        url = "https://github.com/rhboot/efivar/commit/ca48d3964d26f5e3b38d73655f19b1836b16bd2d.patch";
        hash = "sha256-DkNFIK4i7Eypyf2UeK7qHW36N2FSVRJ2rnOVLriWi5c=";
      })
    ];
  });
}
