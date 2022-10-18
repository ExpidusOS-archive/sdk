{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, dbus, vala, vadi, libtokyo, gtk-layer-shell, libpeas, libdevident }:
with lib;
stdenv.mkDerivation rec {
  pname = "genesis-shell";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    rev = "9db39f9cb2017db03ca4c94409aeee19073940f2";
    sha256 = "0EwB2o9e+vZi0CSsmzyzepFN8lCd4w5VzO7ovcCm34Y=";
  };

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection ];
  buildInputs = [ vadi libdevident libtokyo libpeas dbus ]
    ++ optional stdenv.isLinux gtk-layer-shell;
  propagatedBuildInputs = buildInputs;

  mesonFlags = optional stdenv.isDarwin "-Ddbus=disabled";

  meta = with lib; {
    description = "The next generation desktop and mobile shell";
    homepage = "https://github.com/ExpidusOS/genesis";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
