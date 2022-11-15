{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  nixpkgs ? import ../../lib/channels/nixpkgs.nix,
  homeManager ? import ../../lib/channels/home-manager.nix,
  sdk ? ../..,
  ...
}@args:
let
  channels = {
    inherit nixpkgs sdk;
    home-manager = homeManager;
  };
in
(import ./overlay.nix channels) (builtins.removeAttrs args [ "sdk" "nixpkgs" ])
