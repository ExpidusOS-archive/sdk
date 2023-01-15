{ lib, callPackage }:
with lib;
let
  pkg = callPackage ./package.nix {};
in pkg {
  rev = "aa4201eb35e0f508129a2a217c22a511466a8602";
  sha256 = "sha256-dxTyiQToBk9/VgMowNp+zGzeG47X7ucLSJuMSl7Nbsg=";
}
