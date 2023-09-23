{ lib, fetchFromGitHub, runCommand, flutter, pkg-config, expidus }@pkgs:
let
  rev = "924750b6cbe96476dc2470e43e32f6dd1324d6e6";
in
flutter.buildFlutterApplication {
  pname = "genesis-shell";
  version = "0.2.0+git-${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    inherit rev;
    sha256 = "sha256-zu6OABmcsathAr0RpQHuLoE5eOFT2qEVzxQnUrcM96o=";
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
