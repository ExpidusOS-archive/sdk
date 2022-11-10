{ nixpkgsPath, ... }@channels:
let
  lib = import (nixpkgsPath + "/lib/default.nix");
  makeExtendible = name: base:
    let
      self = (import "${nixpkgsPath}/lib/fixed-points.nix" { inherit lib; }).makeExtensible (self:
        let
          call = file: import file { ${name} = self; };
        in base { inherit call self; ${name} = self; });
    in self;
in makeExtendible "expidus" ({ call, self, expidus }: {
  inherit nixpkgsPath makeExtendible channels;

  maintainers = import ./maintainers.nix;
  trivial = import ./trivial.nix { inherit lib; };
})
