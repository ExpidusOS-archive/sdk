{ lib, stdenv, stdenvNoCC, hostPlatform, callPackage, fetchFromGitHub, fetchurl, writeText, makeWrapper, ninja, gnumake, patchelf, python3, cacert, clang-tools, pkg-config, openssh, git, gclient-wrapped }:
{ runtimeMode, sha256 }:
with lib;
let
  version = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";

  ## Note: this must match Flutter Engine's DEPS file
  flutter-deps = filterAttrs (name: pkg: isAttrs pkg && hasAttr "outPath" pkg) (callPackage ./deps.nix {});

  toolchainArch = if hostPlatform.isx86_64 then "amd64" else if hostPlatform.isAarch64 then "aarch64" else throws "Unsupported platform";
  interpreter = "ld-linux-${hostPlatform.parsed.cpu.arch}.so.2";
in stdenvNoCC.mkDerivation rec {
  pname = "flutter-engine-${runtimeMode}";
  inherit version runtimeMode;

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

  nativeBuildInputs = [ openssh git gclient-wrapped clang-tools makeWrapper patchelf python3 pkg-config ninja stdenv.cc.libc ];

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

  binaryFixes = [
    "src/third_party/dart/tools/sdks/dart-sdk/bin/dart"
    "src/flutter/third_party/gn/gn"
  ];

  shellFixes = [
    "src/third_party/dart/tools/sdks/dart-sdk/bin/dart2js"
    "src/flutter/tools/gn"
  ];

  unpackPhase = ''
    cd $NIX_BUILD_TOP

    mkdir -p src
    cp --no-preserve=ownership $gclientFile .gclient
    ${concatStringsSep "\n" (attrValues (mapAttrs (name: src: ''
      if [[ ! -z $(dirname ${name}) ]]; then
        mkdir -p $(dirname ${name})
      fi

      cp -r -P --no-preserve=ownership ${src} ${name}
      chmod -R 0755 ${name}
    '') flutter-deps))}

    for bin in $binaryFixes; do
      chmod 0755 $bin
      patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $bin
    done

    for bin in $(find src/buildtools/ -type l); do
      chmod 0755 $bin
      patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $bin || true
    done

    for sh in $shellFixes; do
      chmod 0755 $sh
      patchShebangs $sh
    done

    sed -i '1 s|^.*$|#!${gnumake}/bin/make -f|' src/third_party/harfbuzz/src/update-unicode-tables.make

    mkdir -p src/build/linux/debian_sid_${toolchainArch}-sysroot
    tar -xf $toolchain -C src/build/linux/debian_sid_${toolchainArch}-sysroot
  '';

  configurePhase = ''
    cd $NIX_BUILD_TOP

    python3 src/third_party/dart/tools/generate_package_config.py
    python3 src/third_party/dart/tools/generate_sdk_version_file.py
    python3 src/tools/remove_stale_pyc_files.py src/tools
    python3 src/flutter/tools/pub_get_offline.py

    ./src/flutter/tools/gn --runtime-mode $runtimeMode --no-build-glfw-shell --prebuilt-dart-sdk --embedder-for-target --no-goma --target-dir build
  '';

  buildPhase = ''
    cd $NIX_BUILD_TOP

    echo "Building flatc"
    ninja -C src/out/build flatc
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} src/out/build/flatc
    
    echo "Building blobcat"
    ninja -C src/out/build blobcat
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} src/out/build/blobcat
    
    echo "Building gen_snapshot"
    ninja -C src/out/build gen_snapshot
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} src/out/build/gen_snapshot

    echo "Building impellerc"
    ninja -C src/out/build impellerc
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} src/out/build/impellerc

    echo "Building Flutter Engine library"
    ninja -C src/out/build flutter_engine_library

    echo "Building icudtl.dat"
    ninja -C src/out/build icudtl.dat

    ninja -C src/out/build flutter_embedder.h
  '';

  installPhase = ''
    cd $NIX_BUILD_TOP

    mkdir -p $out/lib/flutter-$runtimeMode $out/lib/pkgconfig
    cp src/out/build/libflutter_engine.so $out/lib/flutter-$runtimeMode
    cp src/out/build/icudtl.dat $out/lib/flutter-$runtimeMode
    cp src/out/build/flutter_embedder.h $out/lib/flutter-$runtimeMode
    substituteAll ${./flutter-engine.pc} $out/lib/pkgconfig/flutter-engine-$runtimeMode.pc
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = sha256;
}
