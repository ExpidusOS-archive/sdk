{ lib, stdenv, fetchFromGitHub, vala, meson, ninja, pkg-config, glib, gobject-introspection }:
stdenv.mkDerivation rec {
  pname = "vadi";
  version = "0.2.0";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "Vadi";
    rev = "fbe39ef910dfdca2fddcccee115738885cd595e8";
    sha256 = "0fkaz24p2ilr492xykj944vcvfczm8jy67zmsfj92cgpg7dq1zqp";
  };

  nativeBuildInputs = [ pkg-config vala meson ninja pkg-config gobject-introspection ];
  buildInputs = [ glib ];

  PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_GIRDIR = "${placeholder "dev"}/share/gir-1.0";
  PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_TYPELIBDIR = "${placeholder "out"}/lib/girepository-1.0";

  meta = with lib; {
    description = "An IoC Container for Vala";
    homepage = "https://github.com/nahuelwexd/Vadi";
    license = licenses.lgpl3Only;
    maintainers = [ "Tristan Ross" "Nahu" ];
  };
}
