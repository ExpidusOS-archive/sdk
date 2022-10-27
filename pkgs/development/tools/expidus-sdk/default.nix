{ lib, stdenv, meson, ninja, pkg-config, uncrustify, clang_14, vala, nix, glib, git }:
with lib;
stdenv.mkDerivation rec {
  name = "expidus-sdk";
  src = ../../../../.;
  
  configurePlatforms = [ "host" "build" "target" ];
  configureFlags = [ "--bindir=$system/bin" "--datadir=$system/share" ];

  outputs = [ "out" "system" ];

  setupHooks = [ ./setup-hook.sh ];
  enableParallelBuilding = true;

  nativeBuildInputs = [ meson ninja pkg-config uncrustify clang_14 vala nix ];
  buildInputs = [ glib ];

  postInstall = ''
    mkdir -p $system/bin $system/etc $system/share
    cp system/expidus-version $system/bin/expidus-version
    cp system/lsb-release $system/etc/lsb-release
    cp system/os-release $system/etc/os-release
    cp -r system/po $system/share/locale
  '';

  meta = with lib; {
    homepage = "https://github.com/ExpidusOS/sdk";
    license = with licenses; [ gpl3Only ];
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
