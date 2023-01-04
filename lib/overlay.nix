{ nixpkgs, ... }@channels: (import (nixpkgs + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix channels;
  attrsets = prev.attrsets // {
    mapRename = func: attrs: builtins.listToAttrs (builtins.attrValues (builtins.mapAttrs (name: value: {
      name = func name value;
      inherit value;
    }) attrs));
  };
  systems = prev.systems // {
    examples = final.expidus.system.supportedSystems;
  };
})
