{ pkgs ? (import ./.. { }), nixpkgs ? { }}:
let
  lib = pkgs.lib;
  doc-support = import ./doc-support { inherit pkgs nixpkgs; };
in pkgs.stdenv.mkDerivation {
  name = "expidus-manual";

  nativeBuildInputs = with pkgs; [
    pandoc
    graphviz
    libxml2
    libxslt
    zip
    jing
    xmlformat
  ];

  src = lib.cleanSource ./.;

  postPatch = ''
    ln -s ${doc-support} ./doc-support/result
  '';

  installPhase = ''
    dest="$out/share/doc/expidus"
    mkdir -p "$(dirname "$dest")"
    mv out/html "$dest"
    mv "$dest/index.html" "$dest/manual.html"

    mv out/epub/manual.epub "$dest/expidus-manual.epub"

    mkdir -p $out/nix-support/
    echo "doc manual $dest manual.html" >> $out/nix-support/hydra-build-products
    echo "doc manual $dest expidus-manual.epub" >> $out/nix-support/hydra-build-products
  '';

  # Environment variables
  PANDOC_LUA_FILTERS_DIR = "${pkgs.pandoc-lua-filters}/share/pandoc/filters";
}
