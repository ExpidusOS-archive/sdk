{ lib, stdenv, buildPackages, fetchFromGitHub, plymouth }:
with lib;
let
  rev = "101e674e914d2fc8bf235039b34312244ac22b6c";
  branch = "master";
  version = "git+${rev}";
in
stdenv.mkDerivation {
  pname = "expidus-launcher";
  inherit version;

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "launcher";
    inherit rev;
    sha256 = "sha256-nT2qRe9NoRYzu3vdYO11Rta+OjYjIAMsDTe0zBaRtv4=";
  };

  nativeBuildInputs = with buildPackages; [
    buildPackages.expidus.sdk
    meson
    ninja
    pkg-config
  ];

  buildInputs = optional plymouth.meta.available plymouth;

  mesonFlags = [
    "-Dgit-commit=${builtins.substring 0 7 rev}"
    "-Dgit-branch=${branch}"
    "-Dplymouth=${if plymouth.meta.available then "enabled" else "disabled"}"
  ];

  postInstall = ''
    mkdir -p $out/bin
  '';

  meta = {
    description = "Shell launcher for ExpidusOS";
    homepage = "https://github.com/ExpidusOS/launcher";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ RossComputerGuy ];
  };
}
