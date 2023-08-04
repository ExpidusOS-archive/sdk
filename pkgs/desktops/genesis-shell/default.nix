{ lib, fetchFromGitHub, runCommand, flutter, flutter-engine, pkg-config, expidus }@pkgs:
let
  rev = "82aa28024ec804777a1b9469badd5b88fecc3f79";

  flutterEngine = runCommand flutter-engine.name {} ''
    mkdir -p $out/src
    find ${pkgs.flutter-engine.src}/src -maxdepth 1 -mindepth 1 -exec ln -sf {} $out/src \;
    ln -s ${pkgs.flutter-engine}/out $out/src/out
  '';
in
flutter.buildFlutterApplication {
  pname = "genesis-shell";
  version = "0.2.0+git-${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    inherit rev;
    sha256 = "sha256-5/migW//BoX221MtTcwJVc0cZ6/GqWHSchYjI7FgnIk=";
  };

  depsListFile = ./deps.json;
  vendorHash = "sha256-dKI0y8qEmxqv4a/+pR0Yx+wT7kSJcJRCl2kQCi68TEk=";

  nativeBuildInputs = [
    pkg-config
  ];

  flutterBuildFlags = [
    "--local-engine=${flutterEngine}/src/out/host_release"
    "--local-engine-src-path=${flutterEngine}/src"
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
