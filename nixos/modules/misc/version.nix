args@{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.system.nixos;
  opt = options.system.nixos;
in {
  options.system = {
    nixos.version = mkOption {
      internal = true;
      type = types.str;
      description = "The full NixOS version (e.g. <literal>16.03.1160.f2d4ee1</literal>).";
    };

    nixos.release = mkOption {
      readOnly = true;
      type = types.str;
      default = trivial.release;
      description = "The NixOS release (e.g. <literal>16.03</literal>).";
    };

    nixos.versionSuffix = mkOption {
      internal = true;
      type = types.str;
      default = trivial.versionSuffix;
      description = "The NixOS version suffix (e.g. <literal>1160.f2d4ee1</literal>).";
    };

    nixos.revision = mkOption {
      internal = true;
      type = types.nullOr types.str;
      default = trivial.revisionWithDefault null;
      description = "The Git revision from which this NixOS configuration was built.";
    };

    nixos.codeName = mkOption {
      readOnly = true;
      type = types.str;
      default = trivial.codeName;
      description = "The NixOS release code name (e.g. <literal>Emu</literal>).";
    };

    stateVersion = mkOption {
      type = types.str;
      default = "22.05";
      description = ''
        Every once in a while, a new NixOS release may change
        configuration defaults in a way incompatible with stateful
        data. For instance, if the default version of PostgreSQL
        changes, the new version will probably be unable to read your
        existing databases. To prevent such breakage, you should set the
        value of this option to the NixOS release with which you want
        to be compatible. The effect is that NixOS will use
        defaults corresponding to the specified release (such as using
        an older version of PostgreSQL).
        It‘s perfectly fine and recommended to leave this value at the
        release version of the first install of this system.
        Changing this option will not upgrade your system. In fact it
        is meant to stay constant exactly when you upgrade your system.
        You should only bump this option, if you are sure that you can
        or have migrated all state on your system which is affected
        by this option.
      '';
    };

    defaultChannel = mkOption {
      internal = true;
      type = types.str;
      default = "https://github.com/ExpidusOS/sdk/archive/refs/heads/master.tar.gz";
      description = "Default NixOS channel to which the root user is subscribed.";
    };

    configurationRevision = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The Git revision of the top-level flake from which this configuration was built.";
    };
  };

  config = {
    system.nixos = {
      version = mkDefault (cfg.release + cfg.versionSuffix);
    };

    system.stateVersion = "22.05";

    environment.etc = {
      "lsb-release".source = "${pkgs.expidus-sdk.sys}/etc/lsb-release";
      "os-release".source = "${pkgs.expidus-sdk.sys}/etc/os-release";
    };

    boot.initrd.systemd.contents = {
      "/etc/os-release".source = "${pkgs.expidus-sdk.sys}/etc/os-release";
      "/etc/initrd-release".source = "${pkgs.expidus-sdk.sys}/etc/os-release";
    };
  };

  meta.buildDocsInSandbox = false;
}
