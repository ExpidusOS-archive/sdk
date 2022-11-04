{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, vala, gobject-introspection, glib, sass, nodejs, vadi, gtk3, gtk4, libhandy, libadwaita, ntk, expidus-sdk, libical }:
stdenv.mkDerivation rec {
  pname = "libtokyo";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libtokyo";
    rev = "13781b25334f5d44dc2205df33f81a3dc34f3b9e";
    sha256 = "RZiOexY4zRl7nC7UgRktAGTXXym1D3lvr7MI8ulnGeY=";
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
