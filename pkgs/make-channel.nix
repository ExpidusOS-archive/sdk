{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  nixpkgsPath ? import ../lib/channels/nixpkgs.nix,
  sdkPath ? ../.,
  ...
}@args:
(import ./overlay.nix { inherit nixpkgsPath sdkPath; }) (builtins.removeAttrs args [ "nixpkgsPath" "sdkPath" ])
