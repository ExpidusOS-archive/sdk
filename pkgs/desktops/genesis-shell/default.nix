{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, dbus, vala, vadi, libtokyo, gtk-layer-shell, libpeas, libdevident }:
with lib;
stdenv.mkDerivation rec {
  pname = "genesis-shell";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    fetchSubmodules = true;
    rev = "f82e9b69fe8f5631409d937cd04e934995638c66";
    sha256 = "uD9NRfP9dtgIzP1eVaqSbX2VlbLWhK8UAT91OeaYdcM=";
  };

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection ];
  buildInputs = [ vadi libdevident libtokyo libpeas dbus ];
    # FIXME: add vapi (++ lib.optional stdenv.isLinux gtk-layer-shell;)
  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "The next generation desktop and mobile shell";
    homepage = "https://github.com/ExpidusOS/genesis";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
