{ lib, fetchFromGitHub, clang14Stdenv, buildPackages, check, flutter-engine, libglvnd, pixman }:
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
    bootstrap ? false,
    mesonFlags ? [],
    passthru ? {},
    buildType ? "release",
    sha256 ? fakeHash
  }@args:
    clang14Stdenv.mkDerivation {
      pname = "neutron${optionalString bootstrap "-bootstrap"}";
      version = "git+${builtins.substring 0 7 rev}";

      inherit src;

      outputs = [ "out" "dev" "devdoc" ];

      nativeBuildInputs = with buildPackages; [
        expidus.sdk
        meson
        ninja
        pkg-config
        gtk-doc
        libxslt
        docbook_xsl
        docbook_xml_dtd_412
        docbook_xml_dtd_42
        docbook_xml_dtd_43
      ] ++ optionals (!bootstrap) [
        flutter-engine
        libglvnd
        pixman
      ];

      buildInputs = optional check.meta.available check;
      doCheck = check.meta.available;

      mesonBuildType = buildType;
      mesonFlags = mesonFlags ++ [
        "-Dgit-commit=${builtins.substring 0 7 rev}"
        "-Dgit-branch=${branch}"
        "-Dbootstrap=${if bootstrap then "true" else "false"}"
      ];

      passthru = passthru // {
        inherit mkPackage rev branch;
      } // optionalAttrs (!bootstrap) {
        bootstrap = mkPackage (args // {
          bootstrap = true;
        });
      };

      meta = {
        description = "Core API for ExpidusOS";
        homepage = "https://github.com/ExpidusOS/neutron";
        license = licenses.gpl3Only;
        maintainers = with maintainers; [ RossComputerGuy ];
      };
    };
in mkPackage
