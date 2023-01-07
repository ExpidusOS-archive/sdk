{ lib, config, ... }:
pkgs: super:
with pkgs;
let
  isCrossCompiling = stdenv.hostPlatform != stdenv.buildPlatform;
in
rec {
  inherit lib;
  path = lib.expidus.channels.sdk;

  nix = super.nix.overrideAttrs (old: {
    doInstallCheck = !isCrossCompiling;
  });

  nwg-drawer = callPackage ../applications/misc/nwg-drawer/default.nix {};

  ninja = if isCrossCompiling then super.ninja.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "NickCao";
      repo = "ninja";
      rev = "92330cc2320cc8aac432d80da12235abcb2bb449";
      sha256 = "G5mIIHET2Wi6RANqAyIiY+APgz7nASYOkNrkjVK14AA=";
    };
  }) else super.ninja;

  grim = super.grim.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ wayland-scanner ];
  });

  elfutils = super.elfutils.overrideAttrs (old: {
    buildInputs = old.buildInputs
      ++ lib.optionals (with stdenv; !cc.isGNU && !(isDarwin && isAarch64)) [ libgcc ];
  });
}
