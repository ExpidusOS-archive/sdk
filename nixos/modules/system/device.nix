{ config, lib, options, ... }:
with lib;
let
  device = if config.system.device != null then config.system.devices.${config.system.device} else null;

  addCheckDesc = desc: elemType: check: types.addCheck elemType check
    // { description = "${elemType.description} (with check: ${desc})"; };

  isNonEmpty = s: (builtins.match "[ \t\n]*" s) == null;
  nonEmptyStr = addCheckDesc "non-empty" types.str isNonEmpty;
in {
  options.system.devices = mkOption {
    description = ''
      An attr set of each device available and their respective module.
    '';
    type = types.attrsOf (types.submodule ({ name, config, ... }: {
      options = {
        name = mkOption {
          description = "Name of the device";
          type = nonEmptyStr;
        };
        module = mkOption {
          description = "Module to use";
          type = types.nullOr types.path;
        };
        isMobile = mkOption {
          description = "Use name as a nixOS Mobile device instead";
          types = type.bool;
        };
      };

      config = {
        name = mkDefault name;
      };
    }));
  };

  options.system.device = mkOption {
    description = ''
      The name of a device in system.devices
    '';
    type = type.nullOr nonEmptyStr;
  };

  imports = if device != null then
    if device.isMobile then
      [("${lib.expidus.channels.mobile-nixos}/lib/configuration.nix" { device = device.name; })]
    else [device.module];
  else [];
}
