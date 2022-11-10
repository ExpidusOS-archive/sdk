args@{ config, lib, pkgs, ... }:
with lib;
let inherit (pkgs) writeScript; in
let
  base = import (lib.expidus.nixpkgsPath + "/nixos/modules/profiles/docker-container.nix") args;
  pkgs2storeContents = l : map (x: { object = x; symlink = "none"; }) l;
in {
  inherit (base) imports boot system;

  system.build.tarball = pkgs.callPackage ../../lib/make-system-tarball.nix {
    contents = [
      {
        source = "${config.system.build.toplevel}/.";
        target = "./";
      }
    ];
    extraArgs = "--owner=0";

    # Add init script to image
    storeContents = pkgs2storeContents [
      config.system.build.toplevel
      pkgs.stdenv
    ];

    # Some container managers like lxc need these
    extraCommands =
      let script = writeScript "extra-commands.sh" ''
            rm etc
            mkdir -p proc sys dev etc
          '';
      in script;
  };
}
