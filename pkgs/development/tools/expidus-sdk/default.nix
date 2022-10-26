{ lib, stdenv, meson, ninja, pkg-config, uncrustify, clang_14, vala, nix, glib }:
with lib;
stdenv.mkDerivation rec {
  name = "expidus-sdk";
  src = ../../../../.;
  
  configurePlatforms = [ "host" "build" "target" ];

  outputs = [ "out" "system" ];

  setupHooks = [ ./setup-hook.sh ];
  enableParallelBuilding = true;

  nativeBuildInputs = [ meson ninja pkg-config uncrustify clang_14 vala nix ];
  buildInputs = [ glib ];

  postInstall = ''
    mkdir -p $system/bin
    cp /build/expidus-sdk/build/system/expidus-version $system/bin/expidus-version
  '';

  meta = with lib; {
    homepage = "https://github.com/ExpidusOS/sdk";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
