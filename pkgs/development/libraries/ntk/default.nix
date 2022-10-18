{ lib, stdenv, fetchFromGitHub, meson, ninja, vala, pkg-config, gobject-introspection, cairo, gtk4, mesa, libglvnd, cssparser, libdrm }:
with lib;
stdenv.mkDerivation rec {
  pname = "ntk";
  version = "0.1.0";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "ntk";
    rev = "161391771bdb4d167dbd0f884fa36b164d8a1bc1";
    sha256 = "j6KWYlio5lHymH9rgPmTmb6NBIuYUHfRsGVzUOa/Pb4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ meson ninja vala pkg-config gobject-introspection ];
  buildInputs = [ cairo gtk4 libglvnd cssparser ] ++ optionals stdenv.isLinux [ mesa libdrm ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = optionals stdenv.isDarwin [ "-Ddrm=disabled" ];

  doChecks = true;

  meta = with lib; {
    homepage = "https://github.com/ExpidusOS/ntk";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
