{ lib, clang14Stdenv, fetchFromGitHub, meson, ninja }:
clang14Stdenv.mkDerivation {
  pname = "expidus-sdk";

  inherit (lib.expidus.trivial) version;
  src = ../../../../..;

  nativeBuildInputs = [ meson ninja ];

  meta = with lib; {
    description = "SDK for ExpidusOS";
    homepage = "https://github.com/ExpidusOS/sdk";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ TheComputerGuy ];
    platforms = builtins.attrValues (lib.expidus.system.default.forAllSystems (system: _: system));
  };
}
