{ lib, stdenv, fetchFromGitHub, cmake, xz, bison, flex }:
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

  nativeBuildInputs = [ cmake xz bison flex ];
  buildInputs = [];

  meta = with lib; {
    homepage = "https://www.darlinghq.org/";
    description = "Darwin/macOS emulation layer for Linux";
    platforms = platforms.unix;
    license = licenses.gpl3Only;
  };
}
