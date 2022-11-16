{
  description = "SDK for ExpidusOS";

  outputs = { self }@inputs:
    let
      lib = (import ./lib).extend (final: prev: {
        expidus = prev.expidus.extend (f: p: {
          trivial = p.trivial // (rec {
            revision = self.shortRev or "dirty";
            revisionTag = "-${revision}";
            version = p.trivial.release + p.trivial.versionSuffix + revisionTag;
          });
        });

        nixos = import ./nixos/lib { lib = final; };
        nixosSystem = args:
          import ./nixos/lib/eval-config.nix (args // {
            modules = args.modules ++ [{
              system.expidus.versionSuffix = self.shortRev or "dirty";
              system.expidus.revision = final.mkIf (self ? rev) self.rev;
            }];
          } // lib.optionalAttrs (! args ? system) {
            system = null;
          });
      });

      sdk-flake = lib.expidus.flake.makeOverride { inherit self; name = "expidus-sdk"; };
    in sdk-flake // ({
      inherit lib self;
      libExpidus = lib.expidus;
      legacyPackages = lib.expidus.system.forAll (system: import ./. { inherit system; });
    });
}
