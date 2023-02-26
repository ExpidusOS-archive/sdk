{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "5b92c067289c5eff253640941a0d48d54bd56720";
  sha256 = "sha256-6lcXqsmaffXBtn5Ajov8oNQ4xaYwRAgxiW9VR3LrOks=";
}
