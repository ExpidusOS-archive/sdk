{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  channels ? {
    nixpkgs = import ../../lib/channels/nixpkgs.nix;
    sdk = ../..;
  },
  ...
}@args:
(import ./overlay.nix channels) (builtins.removeAttrs args [ "channels" ])
