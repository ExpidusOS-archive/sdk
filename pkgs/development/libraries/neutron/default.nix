{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, gobject-introspection,
  vala, gxml, vadi, glib, libpeas, expidus-sdk, darwin, windows, upower, git }:
with lib;
let
  rev = "2e0fdd759d42c6e0fb946d6bea1d61f8cdf01269";
in stdenv.mkDerivation rec {
  pname = "neutron";
  version = "0.1.0-${rev}";

  outputs = [ "out" "dev" "devdoc" "viewer" ];

  src = fetchFromGitHub {
    owner = "ExpidusOS";
    repo = "neutron";
    inherit rev;
    sha256 = "+YlcVmDfxvD9afnbVmXOrtJF28JDqQAHStCdZqEWxEY=";
    leaveDotGit = true;
  };

  doChecks = true;

  nativeBuildInputs = [ meson ninja pkg-config gobject-introspection vala expidus-sdk git ];
  buildInputs = [ vadi glib libpeas ]
    ++ (lib.optionals stdenv.isLinux [ upower ])
    ++ (lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ IOKit ]))
    ++ (lib.optionals stdenv.isCygwin (with windows; [ w32api ]));

  propagatedBuildInputs = buildInputs;

  meta = with lib; {
    description = "A common system library for handling things such as rotation, calls, networking, etc.";
    homepage = "https://github.com/ExpidusOS/neutron";
    license = licenses.gpl3Only;
    maintainers = with expidus.maintainers; [ TheComputerGuy ];
  };
}
