{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, dbus, vala, vadi, libtokyo,
  gtk-layer-shell, libpeas, libdevident, wrapGAppsHook, gsettings-desktop-schemas, expidus-sdk, networkmanager,
  upower, libpulseaudio, ibus, callaudiod, feedbackd, gi-docgen, evolution-data-server }:
with lib;
let
  rev = "070b6c9a99de20a89e63f7d5fcfc88c66f5e9bee";
in
stdenv.mkDerivation rec {
  pname = "genesis-shell";
  version = "0.2.0-${rev}";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    inherit rev;
    sha256 = "sha256-LQlVrzl7GeXoOy83mqL7rf/A2A/ueQRjUyXcam26U/Y=";
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
    platforms = lists.subtractLists (builtins.map (name: "${name}-cygwin") [ "i686" "x86_64" ]) (lists.flatten (builtins.attrValues expidus.system.defaultSupported));
  };
}
