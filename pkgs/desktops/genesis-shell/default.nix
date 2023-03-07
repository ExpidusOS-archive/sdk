{ lib, buildExpidusPackage, fetchFromGitHub }:
let
  rev = "0bd5e19cedd8f7a2601d019150c928057c48bc43";
in buildExpidusPackage {
  pname = "genesis-shell";
  version = "git+${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    inherit rev;
    sha256 = lib.fakeHash;
  };

  meta = with lib; {
    description = "The next generation desktop and mobile shell";
    homepage = "https://github.com/ExpidusOS/genesis";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ RossComputerGuy ];
  };
}
