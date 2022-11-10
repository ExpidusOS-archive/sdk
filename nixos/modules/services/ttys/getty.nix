{ config, lib, pkgs, options, ... }@args:
let
  base = (import (lib.expidus.nixpkgsPath + "/nixos/modules/services/ttys/getty.nix")) args;
  cfg = config.services.getty;

  baseArgs = [
    "--login-program" "${cfg.loginProgram}"
  ] ++ lib.optionals (cfg.autologinUser != null) [
    "--autologin" cfg.autologinUser
  ] ++ lib.optionals (cfg.loginOptions != null) [
    "--login-options" cfg.loginOptions
  ] ++ cfg.extraArgs;

  gettyCmd = args: "@${pkgs.util-linux}/sbin/agetty agetty ${lib.escapeShellArgs baseArgs} ${args}";
in base // {
  config = {
    services.getty.greetingLine = lib.mkDefault ''<<< Welcome to ExpidusOS ${lib.expidus.trivial.version} (\m) - \l >>>'';

    systemd.services."getty@" = {
      serviceConfig.ExecStart = [
        "" # override upstream default with an empty ExecStart
        (gettyCmd "--noclear --keep-baud %I 115200,38400,9600 $TERM")
      ];
      restartIfChanged = false;
    };

    systemd.services."serial-getty@" = {
      serviceConfig.ExecStart = [
        "" # override upstream default with an empty ExecStart
        (gettyCmd "%I --keep-baud $TERM")
      ];
      restartIfChanged = false;
    };

    systemd.services."autovt@" = {
      serviceConfig.ExecStart = [
        "" # override upstream default with an empty ExecStart
        (gettyCmd "--noclear %I $TERM")
      ];
      restartIfChanged = false;
    };

    systemd.services."container-getty@" = {
      serviceConfig.ExecStart = [
        "" # override upstream default with an empty ExecStart
        (gettyCmd "--noclear --keep-baud pts/%I 115200,38400,9600 $TERM")
      ];
      restartIfChanged = false;
    };

    systemd.services.console-getty = {
      serviceConfig.ExecStart = [
        "" # override upstream default with an empty ExecStart
        (gettyCmd "--noclear --keep-baud console 115200,38400,9600 $TERM")
      ];
      serviceConfig.Restart = "always";
      restartIfChanged = false;
      enable = lib.mkDefault config.boot.isContainer;
    };

    environment.etc.issue = { # Friendly greeting on the virtual consoles.
      source = pkgs.writeText "issue" ''

        [1;32m${config.services.getty.greetingLine}[0m
        ${config.services.getty.helpLine}

      '';
    };
  };
}
