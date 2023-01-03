{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config,
  gobject-introspection, vala, gxml, vadi, glib, libpeas,
  expidus-sdk, libtokyo, git }:
with lib;
let
  rev = "068c73165449672ad96fed5f70df0845b0069c73";
in stdenv.mkDerivation rec {
  pname = "libdevident";
  version = "0.2.0-${rev}";

  outputs = [ "out" "dev" "devdoc" "viewer" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "libdevident";
    inherit rev;
    sha256 = "+YlcVmDfxvD9afnbVmXOrtJF28JDqQAHStCdZqEWxEY=";
    leaveDotGit = true;
  };

  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config gobject-introspection vala expidus-sdk git ];
  buildInputs = [ vadi glib gxml libpeas libtokyo ];
  propagatedBuildInputs = buildInputs;

  postInstall = ''
    mkdir -p $viewer/bin $viewer/share
    mv $out/bin/devident-gtkviewer $viewer/bin
    mv $out/share/applications $viewer/applications
  '';

  meta = with lib; {
    description = "Device identification library";
    homepage = "https://github.com/ExpidusOS/libdevident";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
