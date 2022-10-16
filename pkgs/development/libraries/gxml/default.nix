{ lib, stdenv, fetchFromGitLab, meson, ninja, pkg-config, gobject-introspection, vala, libxml2, libgee, glib }:
stdenv.mkDerivation rec {
  pname = "gxml";
  version = "0.20.3";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "RossComputerGuy";
    repo = "gxml";
    rev = "f2b778bb0ad0491205c2c55e746bcf3bf59bfdc4";
    sha256 = "5F3ucPRcP+CJphz+I8XMp3w3o1dBQNs+Na1VX67q/T8=";
  };

  doCheck = true;

  PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_GIRDIR = "${placeholder "dev"}/share/gir-1.0";
  PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_TYPELIBDIR = "${placeholder "out"}/lib/girepository-1.0";

  nativeBuildInputs = [ meson ninja pkg-config gobject-introspection vala ];
  buildInputs = [ libxml2 glib libgee ];
  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "GXml provides a GObject API for manipulating XML and a Serializable framework from GObject to XML.";
    homepage = "https://gitlab.gnome.org/GNOME/gxml";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    maintainers = teams.gnome.members;
  };
}
