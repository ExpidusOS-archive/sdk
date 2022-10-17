{ lib, stdenv, fetchFromGitHub, meson, ninja, vala, pkg-config, gobject-introspection, cairo, gtk4, mesa, libglvnd, cssparser }:
with lib;
stdenv.mkDerivation rec {
  pname = "ntk";
  version = "0.1.0";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "ntk";
    fetchSubmodules = true;
    rev = "2b3e30b181a4ab872e837f705fe3a88ef45be73d";
    sha256 = "aQxu5a3/p2uwbAhSQOMqMa2WJuT8PwHIQEYS/gb0LR8=";
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
