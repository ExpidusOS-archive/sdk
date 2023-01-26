{ lib, fetchFromGitHub, clang14Stdenv, buildPackages }:
with lib;
let
  mkPackage = { rev ? "HEAD", branch ? "master", src ? null, buildType ? "release", sha256 ? fakeHash }@args:
    clang14Stdenv.mkDerivation {
      pname = "neutron";
      version = "git+${rev}";

      src = args.src or fetchFromGitHub {
        owner = "ExpidusOS";
        repo = "neutron";
        inherit rev sha256;
      };

      outputs = [ "out" "dev" ];

      nativeBuildInputs = with buildPackages; [
        meson
        ninja
      ];

      mesonBuildType = buildType;
      mesonFlags = [
        "-Dgit-commit=${rev}"
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
