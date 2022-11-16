{ libPath
, pkgsLibPath
, nixosPath
, nixpkgsPath
, sdkPath
, modules
, stateVersion
, release
}@args:
let
  channels = {
    nixpkgs = nixpkgsPath;
  };

  lib = import "${libPath}/overlay.nix" channels;
  modulesPath = "${nixosPath}/modules";
  # dummy pkgs set that contains no packages, only `pkgs.lib` from the full set.
  # not having `pkgs.lib` causes all users of `pkgs.formats` to fail.
  pkgs = import "${nixpkgsPath}/pkgs/pkgs-lib/default.nix" {
    inherit lib;
    pkgs = null;
  };
  utils = import "${nixosPath}/lib/utils.nix" {
    inherit config lib;
    pkgs = null;
  };
  # this is used both as a module and as specialArgs.
  # as a module it sets the _module special values, as specialArgs it makes `config`
  # unusable. this causes documentation attributes depending on `config` to fail.
  config = {
    _module.check = false;
    _module.args = {};
    system.stateVersion = stateVersion;
  };
  eval = lib.evalModules {
    modules = (map (m: "${modulesPath}/${m}") modules) ++ [
      config
    ];
    specialArgs = {
      inherit config pkgs utils;
    };
  };
  docs = import "${nixpkgsPath}/nixos/doc/manual" {
    pkgs = pkgs // {
      inherit lib;
      # duplicate of the declaration in all-packages.nix
      buildPackages.nixosOptionsDoc = attrs:
        (import "${nixpkgsPath}/nixos/lib/make-options-doc")
          ({ inherit pkgs lib; } // attrs);
    };
    config = config.config;
    options = eval.options;
    version = release;
    revision = "release-${release}";
    prefix = modulesPath;
  };
in
  docs.optionsNix
