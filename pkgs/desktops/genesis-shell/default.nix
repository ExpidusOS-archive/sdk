{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection, dbus, vala, vadi, libtokyo,
  gtk-layer-shell, libpeas, libdevident, wrapGAppsHook, gsettings-desktop-schemas, expidus-sdk, networkmanager,
  upower, libpulseaudio, ibus, libgweather }:
with lib;
stdenv.mkDerivation rec {
  pname = "genesis-shell";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "genesis";
    rev = "1393cbfa6dc05b1e3019d892687112178d029bad";
    sha256 = "HR9gE5lQPdZfAc6uZFEeG72TFaMbFAtMAab/sswScUk=";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection wrapGAppsHook expidus-sdk ];
  buildInputs = [ vadi libdevident libtokyo libpeas dbus gsettings-desktop-schemas libgweather ]
    ++ optionals stdenv.isLinux [ gtk-layer-shell networkmanager upower libpulseaudio ibus ];
  propagatedBuildInputs = buildInputs;

  mesonFlags = optionals stdenv.isDarwin [ "-Ddbus=disabled" "-Dx11=disabled" "-Dwayland=disabled" ];

  meta = with lib; {
    description = "The next generation desktop and mobile shell";
    homepage = "https://github.com/ExpidusOS/genesis";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
