{ nixpkgs, ... }@channels: (import (nixpkgs + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix channels;
  systems = prev.systems // {
    examples = builtins.listToAttrs (builtins.map (system: {
      name = system;
      value = {
        inherit system;
      };
    }) final.expidus.system.possible);
  };
})
