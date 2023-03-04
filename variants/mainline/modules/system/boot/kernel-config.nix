{ config, lib, ... }:
with lib;
let
  mergeFalseByDefault = locs: defs:
    if defs == [] then abort "This case should never happen."
    else if any (x: x == false) (getValues defs) then false
    else true;

  kernelItem = with types; submodule {
    options = {
      tristate = mkOption {
        type = enum [ "y" "m" "n" null ];
        default = null;
        internal = true;
        visible = true;
        description = mdDoc ''
          Use this field for tristate kernel options expecting a "y" or "m" or "n".
        '';
      };

      freeform = mkOption {
        type = nullOr str // {
          merge = mergeEqualOption;
        };
        default = null;
        example = ''MMC_BLOCK_MINORS.freeform = "32";'';
        description = mdDoc ''
          Freeform description of a kernel configuration item value.
        '';
      };

      optional = mkOption {
        type = bool // { merge = mergeFalseByDefault; };
        default = false;
        description = mdDoc ''
          Whether option should generate a failure when unused.
          Upon merging values, mandatory wins over optional.
        '';
      };
    };
  };

  mkValue = with lib; val:
    let
      isNumber = c: elem c ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"];
    in
      if (val == "") then "\"\""
      else if val == "y" || val == "m" || val == "n" then val
      else if all isNumber (stringToCharacters val) then val
      else if substring 0 2 val == "0x" then val
      else val; # FIXME: fix quoting one day

  generateNixKConf = exprs:
    let
      mkConfigLine = key: item:
        let
          val = if item.freeform != null then item.freeform else item.tristate;
        in
          if val == null then ""
          else if (item.optional) then "${key}? ${mkValue val}\n"
          else "${key} ${mkValue val}\n";

      mkConf = cfg: concatStrings (mapAttrsToList mkConfigLine cfg);
    in mkConf exprs;
in
{
  options = {
    intermediateNixConfig = mkOption {
      readOnly = true;
      type = types.lines;
      example = ''
        USB? y
        DEBUG n
      '';
      description = mdDoc ''
        The result of converting the structured kernel configuration in settings
        to an intermediate string that can be parsed by generate-config.pl to
        answer the kernel `make defconfig`.
      '';
    };

    settings = mkOption {
      type = types.attrsOf kernelItem;
      example = literalExpression '' with lib.kernel; {
        "9P_NET" = yes;
        USB = option yes;
        MMC_BLOCK_MINORS = freeform "32";
      }'';
      description = mdDoc ''
        Structured kernel configuration.
      '';
    };
  };

  config.intermediateNixConfig = generateNixKConf config.settings;
}
