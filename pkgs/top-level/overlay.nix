{ nixpkgs, expidus-sdk, ... }@channels:
let
  lib = import "${expidus-sdk}/lib/extend.nix" channels;
in
{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  overlays ? [],
  ...
}@args:
  with lib;
  let
    importSystem = name:
      optionalAttrs (builtins.hasAttr name args) {
        "${name}" = {
          system = expidus.system.default.get args."${name}";
        };
      };
    importSystem' = name:
      optionalAttrs (builtins.hasAttr name args) {
        "${name}" = expidus.system.default.get args."${name}";
      };

    config = builtins.removeAttrs args [
      "lib"
      "overlays"
      "localSystem"
      "system"
      "crossSystem"
    ] // {
      inherit lib;
    } // importSystem "localSystem"
      // importSystem' "system"
      // importSystem' "crossSystem";
    pkgs = import "${nixpkgs}/pkgs/top-level/impure.nix" config;
  in pkgs.appendOverlays ([
    (final: prev: { path = expidus-sdk; })
    (import ./all-packages.nix)
  ] ++ overlays)
