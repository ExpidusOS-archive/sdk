{ lib, fetchFromGitHub, stdenv, zig }:
let
  rev = "956c299546ce3c30d15a4d67404839182b701742";
in
stdenv.mkDerivation {
  pname = "expidus-config";
  version = "0.1.0-git+${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "config";
    inherit rev;
    hash = "sha256-fie2J9Dnejm6vBhu9q9LzlLtcSIy2PxTHMC1l93JuVg=";
  };

  nativeBuildInputs = [ zig ];

  buildPhase = ''
    export HOME=$TMPDIR

    zig build --prefix $out -Doptimize=ReleaseSmall
  '';

  doCheck = true;

  checkPhase = ''
    zig build test
  '';

  meta = with lib; {
    description = "Config loader for ExpidusOS";
    homepage = "https://expidusos.com";
    license = licenses.gpl3;
    maintainers = with maintainers; [ RossComputerGuy ];
    platforms = platforms.linux;
    mainProgram = "expidus-config";
  };
}
