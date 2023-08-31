{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.system.rootfs;

  rootfs = import ../../../lib/make-rootfs.nix {
    inherit config lib pkgs;
    inherit (cfg) mutable additionalSpace diskSize options;
    additionalPaths = cfg.storePaths;
  };
in
{
  options = {
    system.rootfs = {
      mutable = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Whether to make an immutable rootfs using squash or a rootfs using ext4";
      };
      diskSize = mkOption {
        type = types.str;
        default = "auto";
        description = mdDoc "The size to allocate for the disk image, auto to automatically allocate.";
      };
      options = mkOption {
        type = with types; listOf str;
        default = [];
        description = mdDoc "The arguments to pass to mkfs";
      };
      additionalSpace = mkOption {
        type = types.str;
        default = "1024M";
        description = mdDoc "Extra space to allocate to the rootfs";
      };
      storePaths = mkOption {
        type = with types; listOf package;
        default = [];
        example = literalExpression "[ pkgs.stdenv ]";
        description = mdDoc ''
          Derivations to be included in the Nix store in the generated rootfs image.
        '';
      };
    };
  };

  config = {
    system.build = {
      inherit rootfs;
    };

    boot.initrd.availableKernelModules = if cfg.mutable then [ "ext4" ] else [ "erofs" ];
  };
}
