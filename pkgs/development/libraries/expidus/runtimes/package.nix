{ lib, clang14Stdenv, fetchFromGitHub, meson, git }:
{ rev, sha256 }:
clang14Stdenv.mkDerivation {
  pname = "expidus-runtimes";
  version = "git+${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "runtimes";
    inherit rev sha256;
    leaveDotGit = true;
  };

  nativeBuildInputs = [ meson git ];

  meta = with lib; {
    description = "Various runtime environments for applications on ExpidusOS";
    homepage = "https://github.com/ExpidusOS/runtimes";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ RossComputerGuy ];
  };
}
