{ lib, stdenv, fetchurl, autoconf, automake, libtool, gnumake, autoreconfHook }:
stdenv.mkDerivation rec {
  pname = "cssparser";
  version = "0.1.0";

  outputs = [ "out" "dev" ];

  src = fetchurl {
    url = "https://github.com/ExpidusOS/cssparser/archive/04aeffe47b1c6b4343e739f5774bcba2fc3632b9.tar.gz";
    sha256 = "qbUPiYy7UbcZk6trQgHpXWmc8WQLuFoHCAwQObDtOhY=";
  };

  nativeBuildInputs = [ autoconf automake libtool gnumake autoreconfHook ];

  meta = with lib; {
    homepage = "https://github.com/pepstack/cssparser";
    license = with licenses; [ mit ];
    maintainers = [ "Tristan Ross" "pepstack" ];
  };
}
