{ lib, stdenv, stdenvNoCC, callPackage, fetchFromGitHub, writeText, makeWrapper, gnumake, patchelf, cacert, clang-tools, openssh, git, gclient-wrapped }:
with lib;
let
  version = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";

  ## Note: this must match Flutter Engine's DEPS file
  flutter-deps = filterAttrs (name: pkg: isAttrs pkg && hasAttr "outPath" pkg) (callPackage ./deps.nix {});

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

    nativeBuildInputs = [ openssh git gclient-wrapped clang-tools gnumake makeWrapper patchelf ];

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
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/src
      cp --no-preserve=ownership $gclientFile $out/.gclient
      cd $out
      gclient sync || true
      
      patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 src/third_party/dart/tools/sdks/dart-sdk/bin/dart

      gclient sync
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = lib.fakeHash;
  };
in src
