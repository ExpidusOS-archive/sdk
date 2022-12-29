{
  nixpkgs ? (import ../../lib/channels/nixpkgs.nix),
  home-manager ? (import ../../lib/channels/home-manager.nix),
  sdk ? (import ../../lib/channels/sdk.nix),
  nixos ? "${nixpkgs}/nixos",
}: rec {
  nixpkgsModules = import "${nixpkgs}/nixos/modules/module-list.nix";

  replacesModules = [
    ({ ... }:
      let
        list = [
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
      in {
        imports = builtins.map (path: "${sdk}/nixos/modules/${path}") list;
        disabledModules = builtins.map (path: "${nixos}/modules/${path}") list;
      })
  ];

  extendModules = [
    ("${home-manager}/nixos")
  ];

  expidusModules = [
    ./misc/expidus-documentation.nix
    ./programs/expidus-terminal.nix
    ./security/apparmor/includes.nix
    ./security/apparmor/profiles.nix
    ./security/expidus.nix
    ./security/wrappers.nix
    ./services/x11/desktop-managers/genesis.nix
    ./system/expidus.nix
  ];

  by-channel = {
    sdk = replacesModules ++ expidusModules;
    home-manager = [ ("${home-manager}/nixos") ];
    nixpkgs = nixpkgsModules;
  };

  allModules = nixpkgsModules ++ replacesModules ++ extendModules ++ expidusModules;
}
