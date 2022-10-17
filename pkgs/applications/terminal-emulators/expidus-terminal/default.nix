{ lib, stdenv, fetchFromGitHub, meson, ninja, vala, pkg-config, libtokyo, vte }:
with lib;
stdenv.mkDerivation rec {
  pname = "expidus-terminal";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "terminal";
    rev = "ee91c8e2aef12575f41cbbe4b6dab9c8ee1b3bc1";
    sha256 = "TZj66FuE/OuwWgv7RaditrZpCTmbW/fjRASajPtPlIk=";
  };

  nativeBuildInputs = [ meson ninja vala pkg-config ];
  buildInputs = [ libtokyo vte ];

  meta = with lib; {
    description = "The terminal for ExpidusOS";
    homepage = "https://github.com/ExpidusOS/terminal";
    license = with licenses; [ gpl3Only ];
    maintainers = with lib.expidus.maintainers; [ TheComputerGuy ];
  };
}
