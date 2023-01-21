{ lib, stdenv, stdenvNoCC, hostPlatform, callPackage, fetchFromGitHub, fetchurl, writeText, makeWrapper, gnumake, patchelf, python3, cacert, clang-tools, pkg-config, openssh, git, gclient-wrapped }:
with lib;
let
  version = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";

  ## Note: this must match Flutter Engine's DEPS file
  flutter-deps = filterAttrs (name: pkg: isAttrs pkg && hasAttr "outPath" pkg) (callPackage ./deps.nix {});

  toolchainArch = if hostPlatform.isx86_64 then "amd64" else if hostPlatform.isAarch64 then "aarch64" else throws "Unsupported platform";
  interpreter = "ld-linux-${hostPlatform.parsed.cpu.arch}.so.2";
in stdenvNoCC.mkDerivation rec {
  pname = "flutter-engine";
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

  binaryFixes = [
    "src/third_party/dart/tools/sdks/dart-sdk/bin/dart"
    "src/flutter/third_party/gn/gn"
  ];

  unpackPhase = ''
    runHook preUnpack

    cd $TMPDIR
    mkdir -p src
    cp --no-preserve=ownership $gclientFile .gclient
    cd $out
    gclient sync --nohooks --no-history
    find src -name '.git' -exec chmod 0755 {} \;
    find src -name '.git' -exec rm -rf {} \; || true

    for bin in $binaryFixes; do
      chmod 0755 $bin
      patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $bin
    done

    for bin in $(find src/buildtools/ -type l); do
      chmod 0755 $bin
      patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $bin || true
    done

    sed -i '1 s|^.*$|#!${gnumake}/bin/make -f|' src/third_party/harfbuzz/src/update-unicode-tables.make

    mkdir -p src/build/linux/debian_sid_${toolchainArch}-sysroot
    tar -xf $toolchain -C src/build/linux/debian_sid_${toolchainArch}-sysroot

    runHook postUnpack
  '';

  configurePhase = ''
    runHook preConfigure
      
    python3 src/third_party/dart/tools/generate_package_config.py
    python3 src/third_party/dart/tools/generate_sdk_version_file.py
    python3 src/tools/remove_stale_pyc_files.py src/tools
    python3 src/flutter/tools/pub_get_offline.py

    ./src/flutter/tools/gn --no-build-glfw-shell --prebuilt-dart-sdk --embedder-for-target --no-goma

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ninja -C src/out/host_debug/ flatc
    patchelf --set-interpreter ${stdenv.cc.libc}/libc/${interpreter} src/out/host_debug/flatc
    
    ninja -C src/out/host_debug/ blobcat
    patchelf --set-interpreter ${stdenv.cc.libc}/libc/${interpreter} src/out/host_debug/blobcat
    
    ninja -C src/out/host_debug/ gen_snapshot
    patchelf --set-interpreter ${stdenv.cc.libc}/libc/${interpreter} src/out/host_debug/gen_snapshot

    ninja -C src/out/host_debug/ impellerc
    patchelf --set-interpreter ${stdenv.cc.libc}/libc/${interpreter} src/out/host_debug/impellerc

    ninja -C src/out/host_debug/ flutter_engine_library

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/lib/flutter
    cp src/out/host_debug/libflutter_engine.so $out/lib
    cp src/out/host_debug/icudtl.dat $out/lib/flutter
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-9pwV+RuqNo+WHZviw+p8kMALqDich531xx1vN5AmBSg=";
}
