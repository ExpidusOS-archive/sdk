{ lib, fetchFromGitHub, runCommand, flutter, pkg-config, expidus }@pkgs:
let
  rev = "bb27f2ef05d3aa8c3250d06df94451dbcf795150";
in
flutter.buildFlutterApplication {
  pname = "genesis-shell";
  version = "0.2.0+git-${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    inherit rev;
    sha256 = "sha256-M4rlp4QQsN+LX+q+tnFQVJ1NkbTC6p4xoXuB4FqBMwc=";
  };

  depsListFile = ./deps.json;
  vendorHash = "sha256-MFiWD7KGrjMga4SxGUNmUIh986xtXM1QjGRK83ENgmI=";

  nativeBuildInputs = [
    pkg-config
  ];

  flutterBuildFlags = [
    "--local-engine=${expidus.gokai.flutter-engine}/out/host_release"
    "--local-engine-src-path=${expidus.gokai.flutter-engine}"
  ];

  buildInputs = [
    expidus.gokai
  ];

  meta = with lib; {
    description = "Next-generation desktop environment for ExpidusOS.";
    homepage = "https://expidusos.com";
    license = licenses.gpl3;
    maintainers = with maintainers; [ RossComputerGuy ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "genesis_shell";
  };
}
