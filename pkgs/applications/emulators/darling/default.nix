{ lib, stdenv, fetchFromGitHub, pkg-config, cmake, xz, bison, flex,
  libcap, ffmpeg, libpulseaudio, libX11, fuse, freetype, libtiff,
  giflib, fontconfig, expat }:
stdenv.mkDerivation rec {
  pname = "darling";
  version = "0.1.20220704";

  src = fetchFromGitHub {
    owner = "darlinghq";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-9PPzkJ38cIs1srtdiLS2Tm+DSiwOdWh1dDqEaeN9mGs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config cmake xz bison flex libcap ];
  buildInputs = [ ffmpeg libpulseaudio libX11 fuse freetype libtiff giflib fontconfig expat ];

  meta = with lib; {
    homepage = "https://www.darlinghq.org/";
    description = "Darwin/macOS emulation layer for Linux";
    platforms = platforms.linux;
    license = licenses.gpl3Only;
  };
}
