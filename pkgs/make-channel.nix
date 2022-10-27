{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  nixpkgsPath ? import ../lib/nixpkgs.nix,
  ...
}@args:
(import ./overlay.nix (nixpkgsPath)) (builtins.removeAttrs args [ "nixpkgsPath" ])
