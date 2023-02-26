{ callPackage, stdenv, isWASM }:
callPackage ./package.nix {
  inherit stdenv isWASM;
} {
  rev = "793a85fa3da9e39127bbffb11de68b56bdfcca25";
  sha256 = "sha256-wY0NLY++b8PBTSTHQS3KyqGmjVDX3VKMNUvp4RLns4Y=";
  inherit isWASM;
}
