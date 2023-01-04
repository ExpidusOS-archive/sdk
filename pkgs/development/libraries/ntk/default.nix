{ lib, stdenv, fetchFromGitHub, meson, ninja, vala, pkg-config, gobject-introspection,
  cairo, gtk4, mesa, libglvnd, cssparser, libdrm, expidus-sdk, git }:
with lib;
let
  rev = "0229e10a2d84060d218d2e1e49e72f10b2e640cc";
in stdenv.mkDerivation rec {
  pname = "ntk";
  version = "0.1.0-${rev}";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "ntk";
    inherit rev;
    sha256 = "sha256-JCRO8GVsHW23pmeImKE9EUp9a73T2mZeO1K1GrDweS0=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  nativeBuildInputs = [ meson ninja vala pkg-config gobject-introspection expidus-sdk git ];
  buildInputs = [ cairo gtk4 libglvnd cssparser ] ++ optionals stdenv.isLinux [ mesa libdrm ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = optionals stdenv.isDarwin [ "-Ddrm=disabled" ];

  doChecks = true;

  meta = with lib; {
    homepage = "https://github.com/ExpidusOS/ntk";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
