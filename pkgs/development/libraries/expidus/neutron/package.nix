{ lib, fetchFromGitHub, clang14Stdenv, buildPackages, check }:
with lib;
let
  mkPackage = {
    rev ? "HEAD",
    branch ? "master",
    src ? fetchFromGitHub {
      owner = "ExpidusOS";
      repo = "neutron";
      inherit rev sha256;
    },
    buildType ? "release",
    sha256 ? fakeHash
  }@args:
    clang14Stdenv.mkDerivation {
      pname = "neutron";
      version = "git+${builtins.substring 0 7 rev}";

      inherit src;

      outputs = [ "out" "dev" "devdoc" ];

      nativeBuildInputs = with buildPackages; [
        meson
        ninja
        pkg-config
        gtk-doc
        libxslt
        docbook_xsl
        docbook_xml_dtd_412
        docbook_xml_dtd_42
        docbook_xml_dtd_43
      ];

      buildInputs = optional check.meta.available check;
      doCheck = check.meta.available;

      mesonBuildType = buildType;
      mesonFlags = [
        "-Dgit-commit=${builtins.substring 0 7 rev}"
        "-Dgit-branch=${branch}"
      ];

      passthru = {
        inherit mkPackage rev branch;
      };

      meta = {
        description = "Core API for ExpidusOS";
        homepage = "https://github.com/ExpidusOS/neutron";
        license = licenses.gpl3Only;
        maintainers = with maintainers; [ RossComputerGuy ];
      };
    };
in mkPackage
