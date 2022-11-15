{
  description = "SDK for ExpidusOS";

  outputs = { self }@inputs:
    let
      lib = import ./lib;
      sdk-flake = lib.expidus.flake.makeOverride { inherit self; name = "expidus-sdk"; };
    in sdk-flake // ({
      inherit lib self;
      libExpidus = lib.expidus;
      legacyPackages = lib.expidus.system.forAll (system: import ./. { inherit system; });
    });
}
