{ nixpkgs, sdk, ... }@channels:
{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  overlays ? [],
  ...
}@args:
let
  config = (builtins.removeAttrs args [ "overlays" ]);
  lib = import ("${sdk}/lib/overlay.nix") channels;

  pkgs = import ("${nixpkgs}/default.nix") config;
in pkgs.appendOverlays ([
    (import ./patch-packages.nix { inherit lib config; })
    (import ./nix-packages.nix { inherit lib config; })
    (import ./all-packages.nix { inherit lib config; })
  ] ++ overlays)
