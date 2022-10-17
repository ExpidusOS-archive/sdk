{
  localSystem ? { system = args.system or builtins.currentSystem; },
  system ? localSystem.system,
  crossSystem ? localSystem,
  ...
}@args:
let
  nixpkgs = import (import ../lib/nixpkgs.nix) args;
  nixpkgs-darwin = import (import ../lib/nixpkgs-darwin.nix) args;
in if nixpkgs.stdenv.isDarwin then nixpkgs-darwin else nixpkgs
