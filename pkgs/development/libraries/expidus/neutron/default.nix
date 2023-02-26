{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "db2b8ce63b60787d907cd1db676b6c792fa78969";
  sha256 = "sha256-kLn+1N9w3wBz0D7CUUX4yRLJ3J/s8ueYq3SwvyIHNUw=";
  inherit isWASM;
}
