{ lib, stdenv, buildPackages, fetchFromGitHub, plymouth }:
with lib;
let
  mkPackage = {
    rev,
    version ? "git+${rev}",
    branch ? "master",
    sha256 ? fakeHash,
    src ? fetchFromGitHub {
      owner = "ExpidusOS";
      repo = "launcher";
      inherit rev sha256;
    }
  }:
  stdenv.mkDerivation {
    pname = "expidus-launcher";
    inherit version src;

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

    passthru = {
      inherit mkPackage;
    };

    meta = {
      description = "Shell launcher for ExpidusOS";
      homepage = "https://github.com/ExpidusOS/launcher";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ RossComputerGuy ];
    };
  };
in mkPackage
