{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.system.rootfs;

  rootfs = import ../../../lib/make-rootfs.nix {
    inherit config lib pkgs;
    inherit (cfg) mutable;
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

  config.system.build = {
    inherit rootfs;
  };
}
