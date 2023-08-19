{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.system.expidus;
  opt = options.system.expidus;

  needsEscaping = s: null != builtins.match "[a-zA-Z0-9]+" s;
  escapeIfNeccessary = s: if needsEscaping s then s else ''"${lib.escape [ "\$" "\"" "\\" "\`" ] s}"'';
  attrsToText = attrs: concatStringsSep "\n" (
    mapAttrsToList (n: v: ''${n}=${escapeIfNeccessary (toString v)}'') attrs
  ) + "\n";

  osReleaseContents = {
    NAME = "${cfg.distroName}";
    ID = "${cfg.distroId}";
    VERSION = "${cfg.release} (${cfg.codename})";
    VERSION_CODENAME = toLower cfg.codename;
    VERSION_ID = cfg.release;
    BUILD_ID = cfg.version;
    PRETTY_NAME = "${cfg.distroName} ${optionalString (cfg.variantName != null) "${cfg.variantName} "}${cfg.version} (${cfg.codename})";
    HOME_URL = optionalString (cfg.distroId == "expidus") "https://expidusos.com";
  } // optionalAttrs (cfg.distroId != "expidus") {
    ID_LIKE = "expidus";
  } // optionalAttrs (cfg.variantId != null) {
    VARIANT_ID = cfg.variantId;
  } // optionalAttrs (cfg.variantName != null) {
    VARIANT = cfg.variantName;
  };

  initrdReleaseContents = osReleaseContents // {
    PRETTY_NAME = "${osReleaseContents.PRETTY_NAME} (Initrd)";
  };

  initrdRelease = pkgs.writeText "initrd-release" (attrsToText initrdReleaseContents);
in
{
  options = {
    boot.initrd.osRelease = mkOption {
      internal = true;
      readOnly = true;
      default = initrdRelease;
    };

    system.expidus = {
      version = mkOption {
        internal = true;
        type = types.str;
        default = expidus.trivial.version;
        description = mdDoc "The full ExpidusOS version";
      };
      release = mkOption {
        internal = true;
        type = types.str;
        default = expidus.trivial.release;
        description = mdDoc "The ExpidusOS release";
      };
      label = mkOption {
        type = types.strMatching "[a-zA-Z0-9:_\\.-]*";
        description = mdDoc "The generated boot label";
      };
      codeName = mkOption {
        internal = true;
        type = types.str;
        default = "Willamette";
        description = mdDoc "The ExpidusOS codename";
      };
      versionSuffix = mkOption {
        internal = true;
        type = types.str;
        default = expidus.trivial.versionSuffix;
        description = mdDoc "The ExpidusOS version suffix";
      };
      revision = mkOption {
        internal = true;
        type = with types; nullOr str;
        default = expidus.trivial.revisionWithDefault null;
        description = mdDoc "The Git revision of ExpidusOS";
      };
      codename = mkOption {
        readOnly = true;
        type = types.str;
        default = expidus.trivial.codename;
        description = mdDoc "The ExpidusOS release code name";
      };
      distroId = mkOption {
        internal = true;
        type = types.str;
        default = "expidus";
        description = mdDoc "The id of the OS";
      };
      distroName = mkOption {
        internal = true;
        type = types.str;
        default = "ExpidusOS";
        description = mdDoc "The name of the OS";
      };
      variantName = mkOption {
        type = with types; nullOr str;
        default = "Mainline";
        description = mdDoc "The name of the specific variant or edition of the OS";
      };
      variantId = mkOption {
        type = with types; nullOr (strMatching "^[a-z0-9._-]+$");
        default = "mainline";
        description = mdDoc "A lower-case string identifying a specific variant or edition of the OS";
      };
      tags = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "with-xen" ];
        description = lib.mdDoc ''
          Strings to prefix to the default
          {option}`system.expidus.label`.

          Useful for not loosing track of configurations built with
          different options, e.g.:

          ```
          {
            system.expidus.tags = [ "with-xen" ];
            virtualisation.xen.enable = true;
          }
          ```
        '';
      };
    };

    system.stateVersion = mkOption {
      type = types.str;
      default = lib.version;
    };
  };

  config = {
    environment.etc = {
      "lsb-release".text = attrsToText {
        LSB_VERSION = "${cfg.release} (${cfg.codename})";
        DISTRIB_ID = "${cfg.distroId}";
        DISTRIB_RELEASE = cfg.release;
        DISTRIB_CODENAME = toLower cfg.codename;
        DISTRIB_DESCRIPTION = "${cfg.distroName} ${optionalString (cfg.variantName != null) "${cfg.variantName} "}${cfg.version} (${cfg.codename})";
      };
      "os-release".text = attrsToText osReleaseContents;
    };

    system.expidus.label = mkDefault (concatStringsSep "-" ((sort (x: y: x < y) cfg.tags) ++ [ cfg.version ]));
  };

  meta.buildDocsInSandbox = false;
}
