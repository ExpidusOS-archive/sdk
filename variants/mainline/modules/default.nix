{ nixpkgs, ... }:
[
  ./system/data.nix
  ./system/vendor-config.nix
  "${nixpkgs}/nixos/modules/misc/assertions.nix"
  "${nixpkgs}/nixos/modules/misc/ids.nix"
  "${nixpkgs}/nixos/modules/misc/lib.nix"
  "${nixpkgs}/nixos/modules/misc/meta.nix"
  "${nixpkgs}/nixos/modules/misc/nixpkgs.nix"
  "${nixpkgs}/nixos/modules/system/etc/etc.nix"
]
