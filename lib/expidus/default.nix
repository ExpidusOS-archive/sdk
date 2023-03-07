{ channels, lib, prev }:
with lib;
fixedPoints.makeExtensible (self:
let
  callPackage = callPackageWith {
    inherit lib prev channels;
  };

  variants = import ../../variants/default.nix {
    inherit channels lib;
  };
in {
  inherit channels variants;

  trivial = callPackage ./trivial.nix {};
  system = callPackage ./system.nix {};
  types = callPackage ./types.nix {};

  inherit (variants) mkMainline;
})
