{ lib, callPackage }:
with lib;
let
  pkg = callPackage ./package.nix {};
in pkg {
  rev = fakeHash;
  sha256 = fakeHash;
}
