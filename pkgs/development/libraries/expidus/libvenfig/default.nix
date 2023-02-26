{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "d25cde06ce04b84082ea6db97d641d053fb06916";
  sha256 = "sha256-wB5ImVCkGo5pYHs220bzBhFyd14uLC5gz6guom5fpYE=";
}
