{ nixpkgs, ... }@channels:
let
  lib = import (nixpkgs + "/lib/default.nix");
  makeExtendible = name: base:
    let
      self = (import "${nixpkgs}/lib/fixed-points.nix" { inherit lib; }).makeExtensible (self:
        let
          call = file: import file { ${name} = self; };
        in base { inherit call self; ${name} = self; });
    in self;
in makeExtendible "expidus" ({ call, self, expidus }: rec {
  inherit makeExtendible channels;

  maintainers = import ./maintainers.nix;
  trivial = import ./trivial.nix { inherit lib; };
  system = import ./system.nix { inherit lib; };
  flake = import ./flake.nix { inherit lib expidus; };

  mkFlake = flake.make;
})
