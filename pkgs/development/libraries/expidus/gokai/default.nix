{ lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  targetPlatform,
  flutter,
  runCommand,
  wayland-scanner,
  meson,
  ninja,
  pkg-config,
  wayland-protocols,
  libxdg_basedir,
  libuv,
  libdrm,
  libevdev,
  glib,
  packagekit,
  wlroots_0_16,
  wayland,
  spdlog,
  yaml-cpp,
  udev,
  glm,
  cairo,
  libglvnd,
  vulkan-loader,
  crossguid,
  libuuid,
  jsoncpp,
  libxkbcommon,
  accountsservice,
  upower,
  flutter-engine
}:
let
  rev = "6a11f0553efc79ed85199e7fa738718489b6a8dd";

  flutter-engineHash = "cdbeda788a293fa29665dc3fa3d6e63bd221cb0d";
  flutter-engines = builtins.mapAttrs
    (name: sha256: runCommand "flutter-engine-${flutter-engineHash}" {
      src = fetchurl {
        url = "https://github.com/ardera/flutter-ci/releases/download/engine%2F${flutter-engineHash}/${name}.tar.xz";
        inherit sha256;
      };
    } ''
      mkdir $NIX_BUILD_TOP/source
      tar xvf $src -C $NIX_BUILD_TOP/source

      mkdir -p $out/out/host_{release,debug,profile}
      cp $NIX_BUILD_TOP/source/gen_snapshot_linux_*_profile $out/out/host_profile/gen_snapshot
      cp $NIX_BUILD_TOP/source/gen_snapshot_linux_*_release $out/out/host_release/gen_snapshot
      cp $NIX_BUILD_TOP/source/gen_snapshot_linux_*_release $out/out/host_debug/gen_snapshot

      for target in profile debug release; do
        cp $NIX_BUILD_TOP/source/libflutter_engine.so.$target $out/out/host_$target/libflutter_engine.so
        cp $NIX_BUILD_TOP/source/icudtl.dat $out/out/host_$target/icudtl.dat
        cp $NIX_BUILD_TOP/source/flutter_embedder.h $out/out/host_$target/flutter_embedder.h
        ln -s ${flutter.dart} $out/out/host_$target/dart-sdk
      done

      mkdir -p $out/src
      ln -s $out/out $out/src/out
    '')
    {
      "aarch64-generic" = "sha256-4F74ZvG05v6s/hat6f0OhRaRGPISqSO8Wk+8xUEof4E=";
    };

  flutter-engine = if pkgs.flutter-engine.meta.broken
    then flutter-engines."${targetPlatform.parsed.cpu.name}-generic"
    else pkgs.flutter-engine;
in
stdenv.mkDerivation rec {
  pname = "gokai";
  version = "0.1.0-git+${rev}";

  outputs = [ "out" "dev" ];

  sourceRoot = "source/packages/gokai_sdk";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "gokai";
    inherit rev;
    sha256 = "sha256-Si4SKHxCkPFMNfdZLKqV15HU/wrE3bSutZ9Y+SrPv+A=";
  };

  nativeBuildInputs = [
    wayland-scanner
    meson
    ninja
    pkg-config
    wayland-protocols
  ];

  buildInputs = [
    libxdg_basedir
    libuv
    glib
    packagekit
    wlroots_0_16
    wayland
    spdlog
    yaml-cpp
    udev
    glm
    cairo
    libglvnd
    vulkan-loader
    crossguid
    libuuid
    jsoncpp
    libxkbcommon
    accountsservice
    libdrm
    libevdev
    upower
  ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = [
    "-Dflutter-engine=${flutter-engine}/out/host_release"
  ];

  postInstall = ''
    cp ${flutter-engine}/out/host_release/libflutter_engine.so $out/lib
  '';

  meta = with lib; {
    maintainers = with maintainers; [ RossComputerGuy ];
    homepage = "https://expidusos.com";
    description = "Gokai - universal framework used by ExpidusOS to develop applications for Windows, Linux, macOS, Android, and the web.";
  };
}
