{ config, lib, pkgs, ... }:
with lib;
let
   makeProg = args: pkgs.substituteAll (args // {
    dir = "bin";
    isExecutable = true;
  });

  nixos-install = makeProg {
    name = "nixos-install";
    src = "${expidus.channels.nixpkgs}/nixos/modules/installer/tools/nixos-install.sh";
    inherit (pkgs) runtimeShell nix;
    path = makeBinPath [
      pkgs.jq
      nixos-enter
    ];
  };

  nixos-enter = makeProg {
    name = "nixos-enter";
    src = "${expidus.channels.nixpkgs}/nixos/modules/installer/tools/nixos-enter.sh";
    inherit (pkgs) runtimeShell;
  };
in
{
  config.system.build = {
    inherit nixos-enter nixos-install;
  };
}
