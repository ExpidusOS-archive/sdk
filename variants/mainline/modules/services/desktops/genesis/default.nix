{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.genesis;
in
{
  options.programs.genesis = {
    enable = mkEnableOption (mdDoc "Next-generation desktop environment for ExpidusOS");
    package = mkOption {
      type = types.package;
      default = pkgs.expidus.genesis-shell;
      defaultText = literalExpression "pkgs.expidus.genesis-shell";
      description = mdDoc "The package providing Genesis Shell";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = true;
      };
    };

    networking.networkmanager.enable = true;

    services.acpid.enable = true;
    services.xserver.enable = true;
    services.accounts-daemon.enable = true;
    services.upower.enable = true;
    security.polkit.enable = true;
    hardware.opengl.enable = mkDefault true;

    fonts = {
      fontDir.enable = true;
      enableDefaultPackages = true;
    };

    services.xserver.displayManager.job.execCmd = ''
      export PATH=${cfg.package}/bin:$PATH
      export XDG_RUNTIME_DIR=/run/genesis-shell
      exec genesis_shell --login
    '';

    systemd = {
      services.display-manager = {
        enable = true;

        onFailure = [
          "getty@tty1.service"
        ];

        conflicts = [
          "getty@tty1.service"
        ];

        before = [
          "graphical.target"
        ];

        after = [
          "getty@tty1.service"
          "rc-local.service"
          "plymouth-quit-wait.service"
          "systemd-user-sessions.service"
        ];

        wants = [
          "upower.service"
          "accounts-daemon.service"
        ];

        unitConfig = {
          ConditionPathExists = "/dev/tty0";
        };

        serviceConfig = {
          RuntimeDirectory = "genesis-shell";
          RuntimeDirectoryMode = "0755";

          User = "genesis";
          PAMName = "login";

          TTYPath = "/dev/tty1";
          TTYReset = "yes";
          TTYVHangup = "yes";
          TTYVTDisallocate = "yes";

          UtmpIdentifier = "tty1";
          UtmpMode = "user";
        };
      };
    };

    users = {
      users.genesis = {
        home = "/var/lib/genesis-shell";
        group = "genesis";
        isSystemUser = true;
        uid = 328;
      };
      groups.genesis.gid = 328;
    };
  };
}
