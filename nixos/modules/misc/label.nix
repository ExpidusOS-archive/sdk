{ config, lib, ... }:
with lib;
let
  cfg = config.system.expidus;
in
{
  imports = [
    (mkRenamedOptionModule [ "system" "nixos" "label" ] [ "system" "expidus" "label" ])
    (mkRenamedOptionModule [ "system" "nixos" "tags" ] [ "system" "expidus" "tags" ])
  ];

  options.system = {
    expidus.label = mkOption {
      type = types.strMatching "[a-zA-Z0-9:_\\.-]*";
      description = lib.mdDoc ''
        ExpidusOS version of "system.nixos.label"
      '';
    };

    expidus.tags = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "with-xen" ];
      description = lib.mdDoc ''
        ExpidusOS version of "system.nixos.tags"
      '';
    };
  };

  config = {
    system.expidus.label = mkDefault (maybeEnv "EXPIDUS_LABEL"
      (concatStringsSep "-" ((sort (x: y: x < y) cfg.tags)
      ++ [ (maybeEnv "EXPIDUS_LABEL_VERSION" cfg.version) ])));
  };
}
