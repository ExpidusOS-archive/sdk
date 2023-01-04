{ lib, clangStdenv, meson, ninja, pkg-config, uncrustify,
  vala, nix, glib, zsh, path, git, variant ? "desktop" }:
with lib;
clangStdenv.mkDerivation rec {
  name = "expidus-sdk";
  src = ../../../../.;
  inherit (lib.expidus.trivial) version;
  
  configurePlatforms = [ "host" "build" "target" ];
  configureFlags = [ "--bindir=$system/bin" "--datadir=$system/share" "-Dvariant=${variant}" ];

  outputs = [ "out" "sys" ];

  setupHooks = [ ./setup-hook.sh ];
  enableParallelBuilding = true;

  nativeBuildInputs = [ meson ninja pkg-config uncrustify vala nix zsh git ];
  buildInputs = [ glib ];

  postInstall = ''
    mkdir -p $sys/bin $sys/etc $sys/share
    cp system/expidus-version $sys/bin/expidus-version
    cp system/lsb-release $sys/etc/lsb-release
    cp system/os-release $sys/etc/os-release
    cp -r system/po $sys/share/locale
  '';

  meta = with lib; {
    description = "A next-gen desktop shell designed for mobile and desktop devices.";
    homepage = "https://github.com/ExpidusOS/sdk";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
    inherit (glib.meta) platforms;
  };
}
