{ lib, fetchFromGitHub, stdenv, zig }:
let
  rev = "f6c1a6348e8d006c3cb5fe9f035054b15d0a9ed8";
in
stdenv.mkDerivation {
  pname = "expidus-config";
  version = "0.1.0-git+${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "config";
    inherit rev;
    hash = "sha256-4CBDOHCx+++u2frVRQJ28rr0rLtkiaFQ97178dv8nCo=";
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
