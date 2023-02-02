{ lib, callPackage }:
with lib;
fixedPoints.makeExtensible (self: {
  sdk = callPackage ../development/tools/expidus/sdk {};

  neutron = callPackage ../development/libraries/expidus/neutron {};
  neutron-bootstrap = self.neutron.bootstrap;
})
