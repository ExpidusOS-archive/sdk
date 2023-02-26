{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "3cfacef30166bdf21929c3f2092d412c8ce42a38";
  sha256 = "sha256-2CCZ+slPUEXX8eo8nsVhPHlti3G3TFSuRf1UxoG4ltU=";
}
