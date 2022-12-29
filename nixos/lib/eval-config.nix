evalConfigArgs@
{
  system ? lib.expidus.system.current,
  pkgs ? (import ../../. { system = lib.expidus.system.current; crossSystem = { inherit system; }; }),
  baseModules ? (import ../modules/module-list.nix {
      inherit (lib.expidus.channels) nixpkgs home-manager sdk;
    }).allModules,
  extraArgs ? {},
  specialArgs ? {},
  modules,
  modulesLocation ? (builtins.unsafeGetAttrPos "modules" evalConfigArgs).file or null,
  check ? true,
  prefix ? [],
  lib ? import ../../lib,
  extraModules ? let e = builtins.getEnv "NIXOS_EXTRA_MODULE_PATH";
    in if e == "" then [] else [(import e)]
}:
let pkgs_ = pkgs;
in
let
  evalModulesMinimal = (import ./default.nix {
    inherit lib;
    featureFlags.minimalModules = { };
  }).evalModules;

  pkgsModule = rec {
    _file = ./eval-config.nix;
    key = _file;
    config = {
      # Explicit `nixpkgs.system` or `nixpkgs.localSystem` should override
      # this.  Since the latter defaults to the former, the former should
      # default to the argument. That way this new default could propagate all
      # they way through, but has the last priority behind everything else.
      nixpkgs.system = lib.mkDefault system;
      nixpkgs.pkgs = pkgs;

      # Stash the value of the `system` argument. When using `nesting.children`
      # we want to have the same default value behavior (immediately above)
      # without any interference from the user's configuration.
      nixpkgs.initialSystem = system;

      _module.args.pkgs = lib.mkIf (pkgs_ != null) (lib.mkForce pkgs_);
    };
  };

  withWarnings = x:
    lib.warnIf (evalConfigArgs?extraArgs) "The extraArgs argument to eval-config.nix is deprecated. Please set config._module.args instead."
    lib.warnIf (evalConfigArgs?check) "The check argument to eval-config.nix is deprecated. Please set config._module.check instead."
    x;

  legacyModules =
    lib.optional (evalConfigArgs?extraArgs) {
      config = {
        _module.args = extraArgs;
      };
    }
    ++ lib.optional (evalConfigArgs?check) {
      config = {
        _module.check = lib.mkDefault check;
      };
    };

  allUserModules =
    let
      # Add the invoking file (or specified modulesLocation) as error message location
      # for modules that don't have their own locations; presumably inline modules.
      locatedModules =
        if modulesLocation == null then
          modules
        else
          map (lib.setDefaultModuleLocation modulesLocation) modules;
    in
      locatedModules ++ legacyModules;

  noUserModules = evalModulesMinimal ({
    inherit prefix specialArgs;
    modules = baseModules ++ extraModules ++ [ pkgsModule modulesModule ];
  });

  # Extra arguments that are useful for constructing a similar configuration.
  modulesModule = {
    config = {
      _module.args = {
        inherit noUserModules baseModules extraModules modules;
      };
    };
  };

  nixosWithUserModules = noUserModules.extendModules { modules = allUserModules; };
in withWarnings nixosWithUserModules // {
  inherit evalConfigArgs;
  inherit extraArgs;
  inherit (nixosWithUserModules._module.args) pkgs;
}
