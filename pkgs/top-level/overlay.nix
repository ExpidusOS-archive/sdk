{ nixpkgs, sdk, ... }@channels:
let
  lib = import ("${sdk}/lib/overlay.nix") channels;
in
{
  localSystem ? { system = args.system or lib.expidus.system.current; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  overlays ? [],
  ...
}@args:
let
  config = builtins.removeAttrs args [ "overlays" ];
  pkgs = import ("${nixpkgs}/default.nix") config;
in pkgs.appendOverlays ([
    (import ./patch-packages.nix { inherit lib config; })
    (import ./nix-packages.nix { inherit lib config; })
    (import ./all-packages.nix { inherit lib config; })
  ] ++ overlays)
