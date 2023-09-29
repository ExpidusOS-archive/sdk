pkgs: prev: with pkgs; {
  expidus = (callPackage ./expidus-packages.nix {}).extend (_: p: prev.expidus // p);
}
