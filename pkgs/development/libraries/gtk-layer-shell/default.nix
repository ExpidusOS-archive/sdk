{ lib, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
, wayland
, gtk3
, gobject-introspection
, vala
}:

stdenv.mkDerivation rec {
  pname = "gtk-layer-shell";
  version = "0.8.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "gtk-layer-shell";
    rev = "a2c481c5eef5014475a2705f92b633d16fa5a99c";
    sha256 = "Z7jPYLKgkwMNXu80aaZ2vNj57LbN+X2XqlTTq6l0wTE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    vala
  ];

  buildInputs = [
    wayland
    gtk3
  ];

  mesonFlags = [
    "-Ddocs=true" "-Dvapi=true" "-Dintrospection=true"
  ];

  meta = with lib; {
    description = "A library to create panels and other desktop components for Wayland using the Layer Shell protocol";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ eonpatapon ];
    platforms = platforms.unix;
  };
}
