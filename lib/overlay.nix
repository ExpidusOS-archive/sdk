{ nixpkgs, home-manager, flake-utils, ... }@channels:
  (import "${nixpkgs}/lib").extend (final: prev: {
    attrsets = prev.attrsets // (with final; {
      renameAttrs = fn: set: listToAttrs (builtins.attrValues (builtins.mapAttrs (name: value: {
        name = fn name value;
        inherit value;
      }) set));
    });

    expidus = import ./extend.nix {
      inherit channels prev;
      lib = final;
    };

    systems = prev.systems // {
      examples = final.expidus.system.default.all-configs;
    };

    hm = (import "${home-manager}/modules/lib/stdlib-extended.nix" final).hm;
    flake-utils = import flake-utils;

    inherit (final.attrsets) renameAttrs;
  })
