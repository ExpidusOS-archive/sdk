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

  mesa = super.mesa.overrideAttrs (old:
    with lib; let
      version = "22.2.5";
      branch = versions.major version;
    in {
      inherit version;

      src = fetchurl {
        urls = [
          "https://archive.mesa3d.org/mesa-${version}.tar.xz"
          "https://mesa.freedesktop.org/archive/mesa-${version}.tar.xz"
          "ftp://ftp.freedesktop.org/pub/mesa/mesa-${version}.tar.xz"
          "ftp://ftp.freedesktop.org/pub/mesa/${version}/mesa-${version}.tar.xz"
          "ftp://ftp.freedesktop.org/pub/mesa/older-versions/${branch}.x/${version}/mesa-${version}.tar.xz"
        ];
        sha256 = "sha256-hQ8GMUb467JirsBPZmwsHlYj8qGYfdok5DYbF7kSxzs=";
      };

      meta = old.meta // {
        changelog = "https://www.mesa3d.org/relnotes/${version}.html";
      };
    });
}
