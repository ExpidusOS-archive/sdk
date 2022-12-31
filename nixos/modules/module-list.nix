{
  nixpkgs ? (import ../../lib/channels/nixpkgs.nix),
  home-manager ? (import ../../lib/channels/home-manager.nix),
  sdk ? (import ../../lib/channels/sdk.nix),
  disko ? (import ../../lib/channels/disko.nix),
  nixos ? "${nixpkgs}/nixos",
}: rec {
  replaces = [
    "misc/documentation.nix"
    "misc/nixpkgs.nix"
    "misc/version.nix"
    "misc/assertions.nix"
    "system/boot/loader/systemd-boot/systemd-boot.nix"
    "system/boot/stage-2.nix"
    "system/boot/stage-1.nix"
    "system/activation/no-clone.nix"
    "system/activation/top-level.nix"
    "system/etc/etc.nix"
    "tasks/network-interfaces.nix"
    "installer/tools/tools.nix"
    "services/misc/gitit.nix"
    "services/misc/nix-daemon.nix"
    "services/editors/emacs.nix"
    "services/ttys/getty.nix"
  ];

  nixpkgsModules =
    let
      list = import "${nixpkgs}/nixos/modules/module-list.nix";
      lib = import "${sdk}/lib/overlay.nix" {
        inherit nixpkgs home-manager sdk;
      };
    in lib.lists.remove (builtins.map (path: "${nixos}/modules/${path}") replaces) list;

  replacesModules = [
    ({ ... }: {
      imports = builtins.map (path: "${sdk}/nixos/modules/${path}") replaces;
      disabledModules = builtins.map (path: "${nixos}/modules/${path}") replaces;
    })
  ];

  extendModules = [
    "${home-manager}/nixos"
    "${disko}/module.nix"
  ];

  expidusModules = [
    ./misc/expidus-documentation.nix
    ./programs/expidus-terminal.nix
    ./programs/flatpak/default.nix
    ./security/apparmor/includes.nix
    ./security/apparmor/profiles.nix
    ./security/expidus.nix
    ./security/wrappers.nix
    ./services/x11/desktop-managers/genesis.nix
    ./system/boot/loader/efi.nix
    ./system/expidus.nix
  ];

  by-channel = {
    sdk = replacesModules ++ expidusModules;
    home-manager = [ ("${home-manager}/nixos") ];
    nixpkgs = nixpkgsModules;
  };

  allModules = nixpkgsModules ++ replacesModules ++ extendModules ++ expidusModules;
}
