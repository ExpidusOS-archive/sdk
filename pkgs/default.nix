import ./overlay.nix {
  nixpkgsPath = (import ../lib/nixpkgs.nix);
  sdkPath = ../.;
}
