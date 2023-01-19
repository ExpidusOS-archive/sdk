{ lib, clang14Stdenv, fetchFromGitHub, meson, ninja,
  depot_tools, cipd,
  flutter-engine ? fetchFromGitHub {
    owner = "flutter";
    repo = "engine";
    rev = "857bd6b74c5eb56151bfafe91e7fa6a82b6fee25";
    sha256 = "sha256-+661KBEcyNj1t0h9rp1kM+hv1DdI/pxxnrJtHihnXyc=";
  }
}:
clang14Stdenv.mkDerivation {
  pname = "expidus-sdk";

  inherit (lib.expidus.trivial) version;
  src = ../../../../..;

  nativeBuildInputs = [ meson ninja ];
  mesonFlags = [ "-Dflutter-engine=${flutter-engine}" "-Ddepot_tools=${depot_tools}" "-Dcipd=${cipd}/bin" ];

  meta = with lib; {
    description = "SDK for ExpidusOS";
    homepage = "https://github.com/ExpidusOS/sdk";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ TheComputerGuy ];
    platforms = builtins.attrValues (lib.expidus.system.default.forAllSystems (system: _: system));
  };
}
