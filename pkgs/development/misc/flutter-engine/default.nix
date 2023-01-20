{ lib, stdenv, stdenvNoCC, hostPlatform, callPackage, fetchFromGitHub, fetchurl, writeText, makeWrapper, gnumake, patchelf, python3, cacert, clang-tools, pkg-config, openssh, git, gclient-wrapped }:
with lib;
let
  version = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";

  ## Note: this must match Flutter Engine's DEPS file
  flutter-deps = filterAttrs (name: pkg: isAttrs pkg && hasAttr "outPath" pkg) (callPackage ./deps.nix {});

  toolchainArch = if hostPlatform.isx86_64 then "amd64" else if hostPlatform.isAarch64 then "aarch64" else throws "Unsupported platform";

  src = stdenvNoCC.mkDerivation rec {
    pname = "flutter-engine-src";
    inherit version;

    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    src = fetchFromGitHub {
      owner = "flutter";
      repo = "engine";
      rev = version;
      sha256 = "sha256-5mKxrm+hvrXeLPjSYihbfd9C5LU1c2IZfqaSy6p/6Vo=";
      leaveDotGit = true;
    };

    toolchain = fetchurl {
      url = "https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/79a7783607a69b6f439add567eb6fcb48877085c/debian_sid_${toolchainArch}_sysroot.tar.xz";
      sha256 = "sha256-+jooJ4YcWHUfD5AT+Yhe0nYQNBl7IvJl2dRc+d3Yl+g=";
    };

    nativeBuildInputs = [ openssh git gclient-wrapped clang-tools makeWrapper patchelf python3 pkg-config ];

    gclientFile = writeText "gclient" ''
      solutions = [
        {
          "managed": False,
          "name": "src/flutter",
          "url": "file://${src}",
          "custom_deps": {
            ${concatStringsSep ",\n" (attrValues (mapAttrs (name: src: "\"${name}\": \"file://${src}\"") flutter-deps))}
          },
          "deps_file": "DEPS",
          "safesync_url": "",
        },
      ]
    '';

    dontUnpack = true;
    dontConfigure = true;
    dontInstall = true;

    binaryFixes = [
      "src/third_party/dart/tools/sdks/dart-sdk/bin/dart"
      "src/flutter/third_party/gn/gn"
    ];

    buildPhase = ''
      mkdir -p $out/src
      cp --no-preserve=ownership $gclientFile $out/.gclient
      cd $out
      gclient sync --nohooks

      for bin in $binaryFixes; do
        chmod 0755 $bin
        patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 $bin
      done

      for bin in $(find src/buildtools/ -type l); do
        chmod 0755 $bin
        patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 $bin || true
      done

      sed -i '1 s|^.*$|#!${gnumake}/bin/make -f|' src/third_party/harfbuzz/src/update-unicode-tables.make

      python3 src/third_party/dart/tools/generate_package_config.py
      python3 src/third_party/dart/tools/generate_sdk_version_file.py
      python3 src/tools/remove_stale_pyc_files.py src/tools

      mkdir -p src/build/linux/debian_sid_${toolchainArch}-sysroot
      tar -xf $toolchain -C src/build/linux/debian_sid_${toolchainArch}-sysroot

      rm -rf .cipd
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-1KlU28IdxkuZv3uyw1rlR2NNBO3W7WSnq/DKV4s6eiU=";
  };
in src
