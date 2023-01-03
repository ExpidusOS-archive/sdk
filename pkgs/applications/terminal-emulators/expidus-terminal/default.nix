{ lib, stdenv, fetchFromGitHub, meson, ninja, vala, pkg-config, libtokyo, vte, expidus-sdk, git }:
with lib;
let
  rev = "ee91c8e2aef12575f41cbbe4b6dab9c8ee1b3bc1";
in stdenv.mkDerivation rec {
  pname = "expidus-terminal";
  version = "0.1.0-${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "terminal";
    inherit rev;
    sha256 = "DemU7V8iy0qH1JFyJw1UOqbYX8NfV3+Ydpq50jR6a+w=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [ meson ninja vala pkg-config expidus-sdk git ];
  buildInputs = [ libtokyo vte ];

  meta = with lib; {
    description = "The terminal for ExpidusOS";
    homepage = "https://github.com/ExpidusOS/terminal";
    license = licenses.gpl3Only;
    maintainers = with lib.expidus.maintainers; [ TheComputerGuy ];
  };
}
