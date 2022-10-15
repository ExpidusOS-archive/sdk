(import ((import ./nixpkgs.nix) + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix;
})
