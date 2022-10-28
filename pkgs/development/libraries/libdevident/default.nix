{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, vala, gxml, vadi, glib, libpeas, expidus-sdk }:
stdenv.mkDerivation rec {
  pname = "libdevident";
  version = "0.2.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libdevident";
    rev = "146d3c55ad53fddecce0e81cd7bea52cae4c759c";
    sha256 = "jZlZOmKgvM6Y1e7GZPxDU2lX9kyUEYKs5RX/s2F+QRM=";
  };

  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config gobject-introspection vala expidus-sdk ];
  buildInputs = [ vadi glib gxml libpeas ];
  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "Device identification library";
    homepage = "https://github.com/ExpidusOS/libdevident";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
