{ lib, stdenv, meson, ninja, pkg-config, uncrustify, clang_14, vala }:
with lib;
stdenv.mkDerivation rec {
  name = "expidus-sdk";
  src = ../../../../../.;

  setupHooks = [ ./setup-hook.sh ];
  enableParallelBuilding = true;

  nativeBuildInputs = [ meson ninja pkg-config ];
  buildInputs = [ uncrustify clang_14 vala ];

  meta = with lib; {
    homepage = "https://github.com/ExpidusOS/sdk";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
