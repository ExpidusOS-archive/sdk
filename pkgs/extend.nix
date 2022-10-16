{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  ...
}@args:
let
  pkgs = import ./base.nix args;
  flake-compat = import (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/99f1c2157fba4bfe6211a321fd0ee43199025dbf.tar.gz";
    sha256 = "0x2jn3vrawwv9xp15674wjz9pixwjyj3j771izayl962zziivbx2";
  });
  defaultNix = src: (flake-compat {
    inherit src system;
  }).defaultNix;
in
with pkgs;
{
  expidus-sdk = (defaultNix ../.).packages.${system}.default;

  cssparser = (defaultNix (fetchTarball {
    url = "https://github.com/ExpidusOS/cssparser/archive/04aeffe47b1c6b4343e739f5774bcba2fc3632b9.tar.gz";
    sha256 = "055b41a3pvyfm2cd09mfxj2hf52svhyzhinjcsq9lh0d050w0irr";
  })).packages.${system}.default;

  expidus-terminal = (defaultNix (fetchFromGithub {
    owner = "ExpidusOS";
    repo = "terminal";
    rev = "0048196021947a70c12fac6ab8f03810dce97ed8";
    fetchSubmodules = true;
    sha256 = "1qfhh00zi977z7f4pfznv84ifksdwj4w4sd9y8amaqgr507l2y5h";
  })).packages.${system}.default;

  genesis-shell = (defaultNix (fetchFromGithub {
    owner = "ExpidusOS";
    repo = "genesis";
    fetchSubmodules = true;
    rev = "f0a5036f977c11628d566c30869ff3bb7d7ca22f";
    sha256 = "10h9ygc3a1z66zbfdswcqmskf120cc7q5zlyknbj55w24x7hcgkk";
  })).packages.${system}.default;

  libdevident = (defaultNix (fetchFromGithub {
    owner = "ExpidusOS";
    repo = "libdevident";
    fetchSubmodules = true;
    rev = "e9f51c20e8465404f7939946ba0d64e9328fd243";
    sha256 = "05prm5acwxmmmwwighsd38zj3vkmpbhdyxnwp6dkqvd2icava00m";
  })).packages.${system}.default;

  ntk = (defaultNix (fetchFromGithub {
    owner = "ExpidusOS";
    repo = "ntk";
    fetchSubmodules = true;
    rev = "000151547a7b1ddd465c4740feeb7d5fff2de84c";
    sha256 = "09bp4cqiy16wg254g0ij6lypxigzyifw4sigifh4zaz7ycmnha4q";
  })).packages.${system}.default;

  vadi = (defaultNix (fetchTarball {
    url = "https://github.com/ExpidusOS/Vadi/archive/fbe39ef910dfdca2fddcccee115738885cd595e8.tar.gz";
    sha256 = "0fkaz24p2ilr492xykj944vcvfczm8jy67zmsfj92cgpg7dq1zqp";
  })).packages.${system}.default;
}
