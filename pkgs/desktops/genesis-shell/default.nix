{ lib, fetchFromGitHub, runCommand, flutter, pkg-config, expidus }@pkgs:
let
  rev = "cc0df545568a68265a44643ce7a568966a99a55d";
in
flutter.buildFlutterApplication {
  pname = "genesis-shell";
  version = "0.2.0+git-${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    inherit rev;
    sha256 = "sha256-JE3RYL7zAkQSSDkBQxVKuwtVDHqURzN0RcyqQP3Kb58=";
  };

  depsListFile = ./deps.json;
  vendorHash = "sha256-1x4683cdTslj6udQKloqwGSs76fCoMSTQ4+aMDnMtPM=";

  nativeBuildInputs = [
    pkg-config
  ];

  flutterBuildFlags = [
    "--local-engine=${expidus.gokai.flutter-engine}/out/host_release"
    "--local-engine-src-path=${expidus.gokai.flutter-engine}"
    "--dart-define=COMMIT_HASH=${rev}"
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
