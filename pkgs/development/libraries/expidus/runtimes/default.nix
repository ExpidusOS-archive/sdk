{ lib, callPackage }:
with lib;
let
  pkg = callPackage ./package.nix {};
in pkg {
  rev = "97253188b752712b2f8aef9d906fdf68d269b157";
  sha256 = "sha256-KvpMe9Jjw+Uw5lhV5yDnTpu0kbiwXcAZ5UR+MtdCFJ8=";
}
