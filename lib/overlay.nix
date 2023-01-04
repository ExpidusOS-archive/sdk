{ nixpkgs, ... }@channels: (import (nixpkgs + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix channels;
  systems = prev.systems // {
    examples = final.expidus.system.supportedSystems;
  };
})
