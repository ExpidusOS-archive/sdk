{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.boot.loader.efi;
  opts = options.boot.loader.efi;

  hasEfiPartition = builtins.length (builtins.attrNames (lib.filterAttrs (name: fs: fs.mountPoint == config.boot.loader.efi.efiSysMountPoint) config.fileSystems)) > 0;
in {
  options.boot.loader.efi.enable = mkEnableOption "Enables EFI support";

  config = mkMerge [
    (mkIf config.boot.loader.systemd-boot.enable {
      boot.loader.efi.enable = true;
    })
    (mkIf hasEfiPartition {
      boot.loader.efi.enable = true;
    })
    {
      assertions = [{
        assertion = cfg.enable -> !pkgs.targetPlatform.isEFI;
        message = "Cannot enable UEFI suppport while EFI is not supported on the target platform";
      }];

      boot.loader.grub.efiSupport = cfg.enable;
    }
  ];
}
