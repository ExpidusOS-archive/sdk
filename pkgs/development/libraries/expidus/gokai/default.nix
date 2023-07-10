{ lib,
  stdenv,
  fetchFromGitHub,
  wayland-scanner,
  meson,
  ninja,
  pkg-config,
  wayland-protocols,
  libxdg_basedir,
  libuv,
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
  flutter-engine
}:
let
  rev = "7bb62afb55694f0aaf48367f801544e91f0cdc23";
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
    sha256 = "sha256-5s+f/fLcN9fou5rYx6sRvxceR9XBMFwP2jwjHuwxmQE=";
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
