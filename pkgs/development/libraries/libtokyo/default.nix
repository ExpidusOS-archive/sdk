{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, vala, gobject-introspection, glib, sass, nodejs, vadi, gtk3, gtk4, libhandy, libadwaita, ntk }:
stdenv.mkDerivation rec {
  pname = "libtokyo";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libtokyo";
    rev = "2ee7d8dac9311888598c9e4be62a02c04d80d093";
    sha256 = "wo4ixqcbqK0nMePSZhfwtnIAmrGoSz2MCdXQGYf/fCA=";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" "devdoc" ];
  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection sass nodejs ];
  buildInputs = [ vadi gtk3 gtk4 libhandy libadwaita ntk ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = ["-Dntk=enabled" "-Dgtk4=enabled" "-Dgtk3=enabled" "-Dnodejs=disabled"];

  meta = with lib; {
    description = "A libadwaita wrapper for ExpidusOS with Tokyo Night's styling";
    homepage = "https://github.com/ExpidusOS/libtokyo";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
