let
  base = import ((import ./nixpkgs.nix) + "/lib/");
  extend = import ./default.nix;
in base // {
  expidus = extend;
}
