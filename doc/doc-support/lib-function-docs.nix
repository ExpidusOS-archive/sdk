# Generates the documentation for library functons via nixdoc. To add
# another library function file to this list, the include list in the
# file `doc/functions/library.xml` must also be updated.

{ pkgs ? import ./.. {}, locationsXml }:

with pkgs; stdenv.mkDerivation {
  name = "expidus-lib-docs";
  src = ./../../lib;

  buildInputs = [ nixdoc ];
  installPhase = ''
    function docgen {
      nixdoc -c "$1" -d "$2" -f "../lib/$1.nix"  > "$out/$1.xml"
    }

    mkdir -p $out
    ln -s ${locationsXml} $out/locations.xml

    docgen flake 'Flake functions'
    docgen system 'System functions'
    docgen trivial 'iscellaneous functions'
  '';
}
