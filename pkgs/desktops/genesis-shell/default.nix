{ lib, fetchFromGitHub, flutter, pkg-config, expidus }:
let
  rev = "75d38e77521bffef7257f70c4b14f9a3aaaa3b13";
in
flutter.buildFlutterApplication {
  pname = "genesis-shell";
  version = "0.2.0+git-${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    inherit rev;
    sha256 = "sha256-R82ghRXl9zTbPt/jySvoQDaz/vgYbibiPtARE00ZjAE=";
  };

  depsListFile = ./deps.json;
  vendorHash = "sha256-Z8YR4QgVWOuB73Qsq5qlXr/SafR9FoZuYBpvyjQOvoo=";

  nativeBuildInputs = [
    pkg-config
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
