{ config, lib, options, ... }@args:
with lib;
let
  device = if config.system.device != null then config.system.devices.${config.system.device} else null;

  module = if device != null then
    (if device.isMobile then (import "${lib.expidus.channels.mobile-nixos}/devices/${device.name}")
    else (import device.module))
  else (args: {});

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
          type = type.bool;
        };
      };

      config = {
        name = mkDefault name;
      };
    }));
    default = {};
  };

  options.system.device = mkOption {
    description = ''
      The name of a device in system.devices
    '';
    type = types.nullOr nonEmptyStr;
    default = null;
  };

  config.nixpkgs.overlays = mkIf (device != null) [
    (self: super: {
      expidus-sdk = super.expidus-sdk.override {
        variant = if device.isMobile then "mobile" else "desktop";
      };
    })
  ];
}
