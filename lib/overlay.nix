{ nixpkgs, home-manager, flake-utils, ... }@channels:
final: prev: {
  attrsets = prev.attrsets // (with final; {
    renameAttrs = fn: set: listToAttrs (builtins.attrValues (builtins.mapAttrs (name: value: {
      name = fn name value;
      inherit value;
    }) set));

    findOne = fn: set: default:
      let
        filtered = filterAttrs fn set;
        keys = attrNames filtered;
        values = attrValues filtered;
      in if length keys == 0 then nameValuePair default default
      else nameValuePair (head keys) (head values);
  });

  expidus = import ./expidus {
    inherit channels prev;
    lib = final;
  };

  systems = prev.systems // {
    examples = final.expidus.system.default.all-configs;
  };

  hm = (import "${home-manager}/modules/lib/stdlib-extended.nix" final).hm;
  inherit (final.expidus.system.default) flake-utils;

  inherit (final.attrsets) renameAttrs;
}
