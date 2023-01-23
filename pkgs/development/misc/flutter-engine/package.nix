{ lib, stdenv, stdenvNoCC, hostPlatform, callPackage, fetchFromGitHub, fetchurl, writeText,
  ninja, gnumake, patchelf, python3, clang-tools, pkg-config, openssh, git, gclient-wrapped }:
{ runtimeMode }:
with lib;
let
  version = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";

  ## Note: this must match Flutter Engine's DEPS file
  flutter-deps = filterAttrs (name: pkg: isAttrs pkg && hasAttr "outPath" pkg) (callPackage ./deps.nix {});

  toolchainArch = if hostPlatform.isx86_64 then "amd64" else if hostPlatform.isAarch64 then "aarch64" else throws "Unsupported platform";
  interpreter = "ld-linux-${hostPlatform.parsed.cpu.arch}.so.2";

  src = stdenvNoCC.mkDerivation {
    pname = "flutter-engine-src";
    inherit version;

    passthru = {
      inherit flutter-deps;
    };

    nativeBuildInputs = [ patchelf python3 ];

    src = fetchFromGitHub {
      owner = "flutter";
      repo = "engine";
      rev = version;
      sha256 = "sha256-5mKxrm+hvrXeLPjSYihbfd9C5LU1c2IZfqaSy6p/6Vo=";
      leaveDotGit = true;
    };

    buildroot = fetchFromGitHub {
      owner = "flutter";
      repo = "buildroot";
      rev = "6af51ff4b86270cc61517bff3fff5c3bb11492e1";
      sha256 = "sha256-03jr3H1RvzGfa0rBPZ1rtNpmieKzDjDgBsrZGaj7vuI=";
    };

    toolchain = fetchurl {
      url = "https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/79a7783607a69b6f439add567eb6fcb48877085c/debian_sid_${toolchainArch}_sysroot.tar.xz";
      sha256 = "sha256-+jooJ4YcWHUfD5AT+Yhe0nYQNBl7IvJl2dRc+d3Yl+g=";
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    gitrev = writeText "git-revision.py" ''
      #!${python3}/bin/python3

      print("${fakeHash}")
    '';

    dartPackageConfig = writeText "dart-package-config.json" ''
      {
        "configVersion": 2,
        "generator": "tools/generate_package_config.dart",
        "packages": []
      }
    '';

    binaryFixes = [
      "src/third_party/dart/tools/sdks/dart-sdk/bin/dart"
      "src/flutter/third_party/gn/gn"
    ];

    shellFixes = [
      "src/third_party/dart/tools/sdks/dart-sdk/bin/dart2js"
      "src/flutter/tools/gn"
    ];

    installPhase = ''
      mkdir -p $out
      cp -r -P --no-preserve=mode,ownership $buildroot $out/src
      cp -r -P --no-preserve=mode,ownership $src $out/src/flutter

      ${concatStringsSep "\n" (attrValues (mapAttrs (name: src: ''
        if [[ -d ${src} ]]; then
          mkdir -p $out/${name}
          cp -r -P --no-preserve=mode,ownership ${src}/* $out/${name}
          find ${src} -type f -name '.*' | xargs -I {} cp --no-preserve=mode,ownership {} $out/${name}
        else
          cp -P --no-preserve=mode,ownership ${src} $out/${name}
        fi
      '') flutter-deps))}

      touch $out/src/third_party/dart/build/config/gclient_args.gni
      cp $gitrev $out/src/flutter/build/git_revision.py

      for bin in $binaryFixes; do
        chmod 0755 $out/$bin
        patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $out/$bin
      done

      for sh in $shellFixes; do
        chmod 0755 $out/$sh
        patchShebangs $out/$sh
      done

      chmod +x $out/src/build/linux/sysroot_ld_path.sh

      sed -i '1 s|^.*$|#!${gnumake}/bin/make -f|' $out/src/third_party/harfbuzz/src/update-unicode-tables.make

      mkdir -p $out/src/build/linux/debian_sid_${toolchainArch}-sysroot
      tar -xf $toolchain -C $out/src/build/linux/debian_sid_${toolchainArch}-sysroot

      cd $out
      mkdir -p $out/src/third_party/dart/.dart_tool
      cp -r --no-preserve=ownership,mode $dartPackageConfig $out/src/third_party/dart/.dart_tool/package_config.json

      python3 $out/src/third_party/dart/tools/generate_package_config.py
      python3 $out/src/third_party/dart/tools/generate_sdk_version_file.py
      python3 $out/src/tools/remove_stale_pyc_files.py src/tools
      python3 $out/src/flutter/tools/pub_get_offline.py
    '';
  };
in stdenvNoCC.mkDerivation rec {
  pname = "flutter-engine-${runtimeMode}";
  inherit version runtimeMode src;

  nativeBuildInputs = [ git python3 pkg-config ninja stdenv.cc.libc ];

  configurePhase = ''
    ./src/flutter/tools/gn \
      --runtime-mode $runtimeMode \
      --no-build-glfw-shell \
      --prebuilt-dart-sdk \
      --embedder-for-target \
      --no-goma \
      --out-dir $out/lib/flutter \
      --target-dir $runtimeMode

    mv $out/lib/flutter/out/$runtimeMode $out/lib/flutter/$runtimeMode
    rmdir $out/lib/flutter/out
  '';

  buildPhase = ''
    echo "Building flatc"
    ninja -C $out/lib/flutter/$runtimeMode flatc
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $out/lib/flutter/$runtimeMode/flatc
    
    echo "Building blobcat"
    ninja -C $out/lib/flutter/$runtimeMode blobcat
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $out/lib/flutter/$runtimeMode/blobcat
    
    echo "Building gen_snapshot"
    ninja -C $out/lib/flutter/$runtimeMode gen_snapshot
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $out/lib/flutter/$runtimeMode/gen_snapshot

    echo "Building impellerc"
    ninja -C $out/lib/flutter/$runtimeMode impellerc
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${interpreter} $out/lib/flutter/$runtimeMode/impellerc

    echo "Building Flutter Engine library"
    ninja -C $out/lib/flutter/$runtimeMode flutter_engine_library

    echo "Building icudtl.dat"
    ninja -C $out/lib/flutter/$runtimeMode icudtl.dat

    ninja -C $out/lib/flutter/$runtimeMode flutter_embedder.h
  '';

  installPhase = ''
    substituteAll ${./flutter-engine.pc} $out/lib/pkgconfig/flutter-engine-$runtimeMode.pc
  '';
}
