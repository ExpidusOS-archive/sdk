{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, vala, gobject-introspection, glib, sass, nodejs, vadi, gtk3, gtk4, libhandy, libadwaita, ntk, expidus-sdk, libical }:
stdenv.mkDerivation rec {
  pname = "libtokyo";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libtokyo";
    rev = "42429929cbf88922e0ea9ca6addbb1f83f8de0fa";
    sha256 = "FJLIVWF55szaPl5iKf/OyRrLwBMnl5c7jkSqBvwlqqU=";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" "devdoc" ];
  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection sass nodejs expidus-sdk ];
  buildInputs = [ vadi gtk3 gtk4 libhandy libadwaita ntk libical ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = ["-Dntk=enabled" "-Dgtk4=enabled" "-Dgtk3=enabled" "-Dnodejs=disabled"];

  meta = with lib; {
    description = "A libadwaita wrapper for ExpidusOS with Tokyo Night's styling";
    homepage = "https://github.com/ExpidusOS/libtokyo";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
