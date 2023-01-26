{ lib, callPackage }:
with lib;
fixedPoints.makeExtensible (self: {
  neutron = callPackage ../development/libraries/expidus/neutron {};
})
