args@{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.system.expidus;
  opt = options.system.expidus;
in {
  disabledModules = [
    "${lib.expidus.channels.nixpkgs}/nixos/modules/misc/label.nix"
  ];

  imports = [
    ./label.nix
    (mkRenamedOptionModule [ "system" "nixos" "version" ] [ "system" "expidus" "version" ])
    (mkRenamedOptionModule [ "system" "nixos" "release" ] [ "system" "expidus" "release" ])
    (mkRenamedOptionModule [ "system" "nixos" "versionSuffix" ] [ "system" "expidus" "versionSuffix" ])
    (mkRenamedOptionModule [ "system" "nixos" "revision" ] [ "system" "expidus" "revision" ])
    (mkRenamedOptionModule [ "system" "nixos" "codeName" ] [ "system" "expidus" "codeName" ])
  ];

  options.system = {
    expidus.version = mkOption {
      internal = true;
      type = types.str;
      default = expidus.trivial.version;
      description = "The full ExpidusOS version (e.g. <literal>16.03.1160.f2d4ee1</literal>).";
    };

    expidus.release = mkOption {
      type = types.str;
      default = expidus.trivial.release;
      description = "The ExpidusOS release (e.g. <literal>16.03</literal>).";
    };

    expidus.versionSuffix = mkOption {
      internal = true;
      type = types.str;
      default = expidus.trivial.versionSuffix;
      description = "The ExpidusOS version suffix (e.g. <literal>1160.f2d4ee1</literal>).";
    };

    expidus.revision = mkOption {
      internal = true;
      type = types.nullOr types.str;
      default = expidus.trivial.revision;
      description = "The Git revision from which this ExpidusOS configuration was built.";
    };

    expidus.codeName = mkOption {
      type = types.str;
      default = expidus.trivial.codeName;
      description = "The ExpidusOS release code name (e.g. <literal>Emu</literal>).";
    };

    stateVersion = mkOption {
      type = types.str;
      default = lib.version;
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
    system.stateVersion = lib.version;

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
