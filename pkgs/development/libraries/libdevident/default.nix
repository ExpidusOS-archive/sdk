{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, vala, gxml, vadi, glib, libpeas }:
stdenv.mkDerivation rec {
  pname = "libdevident";
  version = "0.2.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libdevident";
    rev = "96b8b72a9ac9bda48e0bd17afae9e5155d15dabf";
    sha256 = "c2+kkgaHbiGzIVEFv6eRk3RIFuO6la7L0UO4+rD810Q=";
  };

  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config gobject-introspection vala ];
  buildInputs = [ vadi glib gxml libpeas ];
  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "Device identification library";
    homepage = "https://github.com/ExpidusOS/libdevident";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
