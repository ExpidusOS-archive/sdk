{ nixpkgs, ... }:
[
  "${nixpkgs}/nixos/modules/misc/assertions.nix"
  "${nixpkgs}/nixos/modules/misc/lib.nix"
  "${nixpkgs}/nixos/modules/misc/meta.nix"
  "${nixpkgs}/nixos/modules/misc/nixpkgs.nix"
  "${nixpkgs}/nixos/modules/system/etc/etc.nix"
  "${nixpkgs}/nixos/modules/system/build.nix"
]
