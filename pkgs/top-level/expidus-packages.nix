{ lib, callPackage }:
with lib;
fixedPoints.makeExtensible (self: {
  neutron = callPackage ../development/libraries/expidus/neutron {};
  neutron-bootstrap = self.neutron.bootstrap;
})
