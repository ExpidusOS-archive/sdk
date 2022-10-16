{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, dbus, vala, vadi, libtokyo, gtk-layer-shell, libpeas, libdevident }:
with lib;
stdenv.mkDerivation rec {
  pname = "genesis-shell";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    fetchSubmodules = true;
    rev = "f0a5036f977c11628d566c30869ff3bb7d7ca22f";
    sha256 = "SGJgd7Eh99BNG2IgQP7ozvefNROdwhUyBZQt4/aWN5g=";
  };

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection ];
  buildInputs = [ vadi libdevident libtokyo libpeas dbus ]
    ++ lib.optional stdenv.isLinux gtk-layer-shell;
  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "The next generation desktop and mobile shell";
    homepage = "https://github.com/ExpidusOS/genesis";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
