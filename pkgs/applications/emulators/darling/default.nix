{ lib, clangStdenv, fetchFromGitHub, pkg-config, cmake, xz, bison, flex,
  libcap, ffmpeg, libpulseaudio, libX11, fuse, freetype, libtiff, libbsd,
  giflib, fontconfig, expat, xorg, libGLU, cairo, dbus, pcre2, openssl }:
clangStdenv.mkDerivation rec {
  pname = "darling";
  version = "0.1.20220704";

  src = fetchFromGitHub {
    owner = "darlinghq";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-9PPzkJ38cIs1srtdiLS2Tm+DSiwOdWh1dDqEaeN9mGs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config cmake xz bison flex libcap openssl ];
  buildInputs = [ ffmpeg libpulseaudio libX11 fuse freetype
    libtiff giflib fontconfig expat xorg.libXrandr xorg.libXcursor
    xorg.libXext xorg.libxkbfile xorg.libXdmcp libGLU cairo
    dbus pcre2 libbsd ];

  meta = with lib; {
    homepage = "https://www.darlinghq.org/";
    description = "Darwin/macOS emulation layer for Linux";
    platforms = platforms.linux;
    license = licenses.gpl3Only;
  };
}
