{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, dbus, vala, vadi, libtokyo,
  gtk-layer-shell, libpeas, libdevident, wrapGAppsHook, gsettings-desktop-schemas, expidus-sdk, networkmanager,
  upower, libpulseaudio, ibus, callaudiod, feedbackd, gi-docgen, evolution-data-server }:
with lib;
stdenv.mkDerivation rec {
  pname = "genesis-shell";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    rev = "731341faa82ef7d7009698d4e64bbe204d58c043";
    sha256 = "s63hM4Qe9gdTjF2uft6xGAdK+g09/pnj9cAS/8EHQms=";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection wrapGAppsHook expidus-sdk ]
    ++ optionals stdenv.isLinux [ gi-docgen ];
  buildInputs = [ vadi libdevident libtokyo libpeas dbus gsettings-desktop-schemas ]
    ++ optionals stdenv.isLinux [ gtk-layer-shell networkmanager upower libpulseaudio ibus callaudiod feedbackd evolution-data-server ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = optionals stdenv.isDarwin [ "-Ddbus=disabled" "-Dx11=disabled" "-Dwayland=disabled" ];

  meta = with lib; {
    description = "The next generation desktop and mobile shell";
    homepage = "https://github.com/ExpidusOS/genesis";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
