{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "17b63310a333f0b436a1ba8b96562f983d38b40e";
  sha256 = "sha256-Dbmrn6s42lqDMIGZLYjusEQCfispjm0ntkI2J1BpX3s=";
  inherit isWASM;
}
