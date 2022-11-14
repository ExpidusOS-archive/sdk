with (import ../lib);
{
  nixpkgs ? {
    outPath = cleanSource ../.;
    revCount = 1234;
    shortRev = "abcdef";
    revision = "0000000000000000000000000000000000000000";
  }, ...
}@args:
import "${expidus.channels.nixpkgs}/pkgs/top-level/release.nix" args
