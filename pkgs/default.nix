import ./overlay.nix {
  nixpkgsPath = (import ../lib/channels/nixpkgs.nix);
  sdkPath = ../.;
}
