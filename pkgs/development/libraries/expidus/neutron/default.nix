{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "526556b717f517d58aa9fc9ec2e76ff699481f41";
  sha256 = "sha256-M0dsce21g2DgMHG0raxwW8sHe85JClwpCxG9RwgGeaw=";
  inherit isWASM;
}
