{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  nixpkgs ? import ../../lib/channels/nixpkgs.nix,
  sdk ? ../..,
  ...
}@args:
let
  channels = {
    inherit nixpkgs sdk;
  };
in
(import ./overlay.nix channels) (builtins.removeAttrs args [ "sdk" "nixpkgs" ])
