{ channels, lib, prev }:
with lib;
fixedPoints.makeExtensible (self:
let
  callPackage = callPackageWith {
    inherit lib prev channels;
  };
in {
  inherit channels;

  trivial = callPackage ./trivial.nix {};
  system = callPackage ./system.nix {};
  types = callPackage ./types.nix {};
})
