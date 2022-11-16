{
  nixpkgs ? (import ../../lib/channels/nixpkgs.nix),
  home-manager ? (import ../../lib/channels/home-manager.nix)
}:
let
  nixpkgsModules = import "${nixpkgs}/nixos/modules/module-list.nix";

  replacesModules = builtins.map (path: ({ config, lib, pkgs, ... }: {
    disabledModules = [ "${nixpkgs}/nixos/modules/${path}" ];
    imports = [ ./${path} ];
  })) [
    "misc/nixpkgs.nix"
    "misc/documentation.nix"
    "misc/version.nix"
    "misc/assertions.nix"
    "system/boot/stage-2.nix"
    "system/boot/stage-1.nix"
    "system/activation/no-clone.nix"
    "system/activation/top-level.nix"
    "virtualisation/lxc-container.nix"
    "virtualisation/qemu-vm.nix"
    "profiles/docker-container.nix"
    "profiles/installation-device.nix"
    "profiles/clone-config.nix"
    "installer/tools/tools.nix"
    "services/misc/gitit.nix"
    "services/misc/nix-daemon.nix"
    "services/editors/emacs.nix"
    "services/ttys/getty.nix"
  ];

  expidusModules = [
    ./programs/expidus-terminal.nix
    ./services/x11/desktop-managers/genesis.nix
    ("${home-manager}/nixos")
  ];
in nixpkgsModules ++ replacesModules ++ expidusModules
