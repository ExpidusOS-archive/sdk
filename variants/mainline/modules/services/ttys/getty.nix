{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.getty;

  baseArgs = [
    "--login-program" "${cfg.loginProgram}"
  ] ++ optionals (cfg.autologinUser != null) [
    "--autologin" cfg.autologinUser
  ] ++ optionals (cfg.loginOptions != null) [
    "--login-options" cfg.loginOptions
  ] ++ cfg.extraArgs;

  gettyCmd = args:
    "@${pkgs.util-linux}/sbin/agetty agetty ${escapeShellArgs baseArgs} ${args}";
in
{
  options.services.getty = {
    autologinUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = lib.mdDoc ''
        Username of the account that will be automatically logged in at the console.
        If unspecified, a login prompt is shown as usual.
      '';
    };

    loginProgram = mkOption {
      type = types.path;
      default = "${pkgs.shadow}/bin/login";
      defaultText = literalExpression ''"''${pkgs.shadow}/bin/login"'';
      description = lib.mdDoc ''
        Path to the login binary executed by agetty.
      '';
    };

    loginOptions = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = lib.mdDoc ''
        Template for arguments to be passed to
        {manpage}`login(1)`.
        See {manpage}`agetty(1)` for details,
        including security considerations.  If unspecified, agetty
        will not be invoked with a {option}`--login-options`
        option.
      '';
      example = "-h darkstar -- \\u";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = lib.mdDoc ''
        Additional arguments passed to agetty.
      '';
      example = [ "--nohostname" ];
    };

    greetingLine = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        Welcome line printed by agetty.
        The default shows current NixOS version label, machine type and tty.
      '';
    };

    helpLine = mkOption {
      type = types.lines;
      default = "";
      description = lib.mdDoc ''
        Help line printed by agetty below the welcome line.
        Used by the installation CD to give some hints on
        how to proceed.
      '';
    };
  };

  config = {
    services.getty.greetingLine = mkDefault ''<<< Welcome to ${config.system.expidus.distroName} ${config.system.expidus.codeName} ${config.system.expidus.version} (${config.system.expidus.variantName}, \m) - \l >>>'';

    systemd.services = {
      "getty@" = {
        serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "--noclear --keep-baud %I 115200,38400,9600 $TERM")
        ];
        restartIfChanged = false;
      };
      "serial-getty@" = {
        serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "%I --keep-baud $TERM")
        ];
        restartIfChanged = false;
      };
      "autovt@" = {
        serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "--noclear %I $TERM")
        ];
        restartIfChanged = false;
      };
      "container-getty@" = {
        serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "--noclear --keep-baud pts/%I 115200,38400,9600 $TERM")
        ];
        restartIfChanged = false;
      };
      console-getty = {
        serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "--noclear --keep-baud console 115200,38400,9600 $TERM")
        ];
        serviceConfig.Restart = "always";
        restartIfChanged = false;
        enable = mkDefault config.boot.isContainer;
      };
    };

    environment.etc.issue = mkDefault {
      source = pkgs.writeText "issue" ''

        \e[1;32m${config.services.getty.greetingLine}\e[0m
        ${config.services.getty.helpLine}

      '';
    };
  };
}
