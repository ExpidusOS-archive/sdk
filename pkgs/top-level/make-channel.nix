{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  nixpkgs ? import ../../lib/channels/nixpkgs.nix,
  homeManager ? import ../../lib/channels/home-manager.nix,
  mobileNixos ? import ../../lib/channels/mobile-nixos.nix,
  disko ? import ../../lib/channels/disko.nix,
  sdk ? ../..,
  ...
}@args:
let
  channels = {
    inherit nixpkgs sdk disko;
    home-manager = homeManager;
    mobile-nixos = mobileNixos;
  };
in
(import ./overlay.nix channels) (builtins.removeAttrs args [ "sdk" "nixpkgs" ])
