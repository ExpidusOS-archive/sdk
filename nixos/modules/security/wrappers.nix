{ config, lib, pkgs, ... }:
let
  makeWrapper = cond: name: wrapper:
  let
    caps = wrapper.capabilities or "";
    capList = builtins.filter (name: name != "") (lib.splitString "," caps);
  in
  lib.optionalAttrs cond {
    wrappers.${name} = wrapper;
    apparmor.policies."bin.${name}".profile = lib.mkIf config.security.apparmor.policies."bin.${name}".enable (lib.mkAfter ''
      /run/wrappers/bin/${name} {
        include <abstractions/base>
        include <nixos/security.wrappers>
        rpx /run/wrappers/wrappers.*/${name},
      }
      /run/wrappers/wrappers.*/${name} {
        include <abstractions/base>
        include <nixos/security.wrappers>
        r /run/wrappers/wrappers.*/${name}.real,
        mrpx ${config.security.wrappers.${name}.source},
        ${builtins.concatStringsSep ",\n" (builtins.map (rule: "capability ${rule}") capList)}
        capability setpcap,
      }
    '');
  };
in
{
  /*security = with lib;
    (makeWrapper config.programs.sway.enable "sway" {
      owner = "root";
      group = "proc";
      setgid = true;
      source = "${pkgs.sway}/bin/sway";
    });*/
}
