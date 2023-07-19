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
  rev = "01810e28cdc20e0fa3f42ea006f78e6c661f8b21";
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
