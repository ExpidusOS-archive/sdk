{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, vala, gxml, vadi, glib, libpeas, expidus-sdk }:
stdenv.mkDerivation rec {
  pname = "libdevident";
  version = "0.2.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libdevident";
    rev = "6a9cdc92e35748432037237aabf9411dea38d7af";
    sha256 = "h9oviyMiwDEWxhvfdSZDblQM+KjtK8wphiGZjREQN10=";
  };

  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config gobject-introspection vala expidus-sdk ];
  buildInputs = [ vadi glib gxml libpeas ];
  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "Device identification library";
    homepage = "https://github.com/ExpidusOS/libdevident";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
