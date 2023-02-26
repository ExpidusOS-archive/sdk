{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "2874a61abb61e17b22297f1d05e884df701ca80c";
  sha256 = "sha256-B3gIko3dmygl/ZuHaKUFWVjVP5aXA+93Nb58n1103eE=";
  inherit isWASM;
}
