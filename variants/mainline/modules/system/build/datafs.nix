{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.system.datafs;

  datafs = import ../../../lib/make-datafs.nix {
    inherit config lib pkgs;
    inherit (cfg) mutable additionalSpace diskSize;
  };
in
{
  options = {
    system.datafs = {
      mutable = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Whether to make an immutable datafs using squash or a datafs using ext4";
      };
      diskSize = mkOption {
        type = types.str;
        default = "auto";
        description = mdDoc "The size to allocate for the disk image, auto to automatically allocate.";
      };
      additionalSpace = mkOption {
        type = types.str;
        default = "512M";
        description = mdDoc "Extra space to allocate to the datafs";
      };
    };
  };

  config = {
    system.build = {
      inherit datafs;
    };

    boot.initrd = rec {
      availableKernelModules = if cfg.mutable then [ "ext4" ] else [ "squashfs" ];
      kernelModules = availableKernelModules;
    };
  };
}
