{ config, lib, pkgs, ... }:
with lib;
let
  useHostResolvConf = config.networking.resolvconf.enable && config.networking.useHostResolvConf;

  bootStage2 = pkgs.substituteAll {
    src = ./stage-2-init.sh;
    shellDebug = "${pkgs.bashInteractive}/bin/bash";
    shell = "${pkgs.bash}/bin/bash";
    isExecutable = true;
    inherit (config.boot) systemdExecutable extraSystemdUnitPaths;
    inherit (config.system.expidus) distroName;
    inherit useHostResolvConf;
    inherit (config.system.build) earlyMountScript;
    path = lib.makeBinPath ([
      pkgs.coreutils
      pkgs.util-linux
    ] ++ optional useHostResolvConf pkgs.openresolv);
    postBootCommands = pkgs.writeText "local-cmds" ''
      ${config.boot.postBootCommands}
      ${config.powerManagement.powerUpCommands}
    '';
  };
in
{
  options.boot = {
    postBootCommands = mkOption {
      default = "";
      example = "rm -f /var/log/messages";
      type = types.lines;
      description = mdDoc ''
        Shell commands to be executed just before systemd is started.
      '';
    };

    systemdExecutable = mkOption {
      default = "/run/current-system/systemd/lib/systemd/systemd";
      type = types.str;
      description = mdDoc ''
        The program to execute to start systemd.
      '';
    };

    extraSystemdUnitPaths = mkOption {
      default = [];
      type = with types; listOf str;
      description = mdDoc ''
        Additional paths that get appended to the SYSTEMD_UNIT_PATH environment variable
        that can contain mutable unit files.
      '';
    };
  };

  config.system.build = {
    inherit bootStage2;
  };
}
