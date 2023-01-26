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
  let
    config = builtins.removeAttrs args [ "overlays" "lib" ] // { inherit lib; };
    pkgs = import "${nixpkgs}/pkgs/top-level/impure.nix" config;
  in pkgs.appendOverlays ([
    (final: prev: { path = expidus-sdk; })
    (import ./all-packages.nix)
  ] ++ overlays)
