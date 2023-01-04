{ nixpkgs, ... }@channels: (import (nixpkgs + "/lib/")).extend (final: prev: {
  expidus = import ./extend.nix channels;
  systems = prev.systems // {
    examples =
      let
        systems = final.lists.subtractLists (builtins.map (name: "${name}-darwin") [ "aarch64" "x86_64" ]) final.expidus.system.possible;
      in builtins.listToAttrs (builtins.map (system: {
        name = system;
        value = {
          inherit system;
        };
      }) systems);
  };
})
