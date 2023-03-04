{ nixpkgs, ... }:
[
  ./system/build/activation.nix
  ./system/build/data.nix
  ./system/build/etc.nix
  ./system/build/rootfs.nix
  ./system/build/system-path.nix
  ./system/build/toplevel.nix
  ./system/tools/default.nix
  ./system/vendor-config.nix
  ./system/users.nix
  "${nixpkgs}/nixos/modules/misc/assertions.nix"
  "${nixpkgs}/nixos/modules/misc/ids.nix"
  "${nixpkgs}/nixos/modules/misc/lib.nix"
  "${nixpkgs}/nixos/modules/misc/meta.nix"
  "${nixpkgs}/nixos/modules/misc/nixpkgs.nix"
  "${nixpkgs}/nixos/modules/system/etc/etc.nix"
]
