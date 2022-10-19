{ lib, stdenv, fetchFromGitHub, meson, ninja, vala, pkg-config, gobject-introspection, cairo, gtk4, mesa, libglvnd, cssparser, libdrm }:
with lib;
stdenv.mkDerivation rec {
  pname = "ntk";
  version = "0.1.0";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "ntk";
    rev = "0229e10a2d84060d218d2e1e49e72f10b2e640cc";
    sha256 = "SuO+2ObN4YZndkacIrkJIbaEWi9/lVcxAXhdearJ/LY=";
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
