{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, vala, gobject-introspection, glib, sass, nodejs, vadi, gtk3, gtk4, libhandy, libadwaita, ntk, expidus-sdk }:
stdenv.mkDerivation rec {
  pname = "libtokyo";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libtokyo";
    rev = "bc2acdd846aa393236c4780fe459ca25a6f2573a";
    sha256 = "V4ztuV0QpeVE/a4W6XopH0XgNCHXT/q5aEwjhEEMgxU=";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" "devdoc" ];
  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection sass nodejs expidus-sdk ];
  buildInputs = [ vadi gtk3 gtk4 libhandy libadwaita ntk ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = ["-Dntk=enabled" "-Dgtk4=enabled" "-Dgtk3=enabled" "-Dnodejs=disabled"];

  meta = with lib; {
    description = "A libadwaita wrapper for ExpidusOS with Tokyo Night's styling";
    homepage = "https://github.com/ExpidusOS/libtokyo";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
