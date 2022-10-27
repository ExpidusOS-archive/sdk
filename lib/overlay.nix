nixpkgs: (import (nixpkgs + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix nixpkgs;
})
