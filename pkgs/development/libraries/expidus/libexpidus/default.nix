{ stdenv, callPackage }:
let
  mkPackage = callPackage ./package.nix { inherit stdenv; };
in mkPackage {
  rev = "f39f7e5a2474e68ac4dc7186d8d1e1995f2ac094";
  sha256 = "sha256-J/AxdmE2SA+D8Srw/rMY6RChAlRXr5wTK3SYIplzvso=";
}
