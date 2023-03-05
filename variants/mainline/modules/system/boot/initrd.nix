{ config, lib, pkgs, ... }:
with lib;
{
  options.boot = {
    initrd = {
      enable = mkOption {
        type = types.bool;
        default = !config.boot.isContainer;
        defaultText = literalExpression "!config.boot.isContainer";
        description = mdDoc ''
          Whether to enable the initial ramdisk.
        '';
      };

      extraUdevRulesCommands = mkOption {
        internal = true;
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed in the builder of the
          udev-rules derivation. This can be used to add
          additional udev rules in the initial ramdisk.
        '';
      };
    };
  };
}
