{ lib, buildExpidusPackage, fetchFromGitHub }:
let
  rev = "";
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
