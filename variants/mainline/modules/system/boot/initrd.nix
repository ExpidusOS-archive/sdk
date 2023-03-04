{ config, lib, pkgs, ... }:
let
  initrd = pkgs.makeInitrd {
    name = "initrd";
  };
in
{}
