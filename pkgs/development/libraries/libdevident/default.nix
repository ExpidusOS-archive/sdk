{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, vala, gxml, vadi, glib, libpeas, expidus-sdk, libtokyo }:
stdenv.mkDerivation rec {
  pname = "libdevident";
  version = "0.2.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libdevident";
    rev = "2bae18ff5e50055a90f2159dce7d2a34bddabeee";
    sha256 = "5mkCQL2ixCQv4KC5ggUgaMacss0hKk81qICpwMiHSpc=";
  };

  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config gobject-introspection vala expidus-sdk ];
  buildInputs = [ vadi glib gxml libpeas libtokyo ];
  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "Device identification library";
    homepage = "https://github.com/ExpidusOS/libdevident";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
