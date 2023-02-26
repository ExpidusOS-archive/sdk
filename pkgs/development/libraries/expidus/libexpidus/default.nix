{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "940cd680533efc25a80b7ae902d8d4b894f0a770";
  sha256 = "sha256-pIzgXEKc8oh+Dj4yYrtJw2cqtgRdY7lv8r6H3Gcw5Tg=";
}
