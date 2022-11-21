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

  attrs-overlay = self: super: {
    inherit lib;
    path = sdk;
  };

  pkgs-overlay = import ./all-packages.nix { inherit lib config; };
  pkgs = import ("${nixpkgs}/default.nix") config;
in pkgs.appendOverlays ([
    attrs-overlay
    pkgs-overlay
  ] ++ overlays)
