{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, vala, gobject-introspection, glib, sass, nodejs, vadi, gtk3, gtk4, libhandy, libadwaita, ntk, expidus-sdk, libical }:
stdenv.mkDerivation rec {
  pname = "libtokyo";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libtokyo";
    rev = "68c51b098fc75aace4219b5e6c6e4b005cad6da3";
    sha256 = "03/8f1k/qEE3idqUYYqhZDLMpvI10FaqrUU4uGoyBhE=";
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
