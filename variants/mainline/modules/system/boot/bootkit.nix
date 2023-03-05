{ config, lib, pkgs, ... }:
with lib;
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
}
