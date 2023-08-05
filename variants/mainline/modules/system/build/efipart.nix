{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.boot.efi;

  efipart = import ../../../lib/make-efipart.nix {
    inherit config lib pkgs;
    inherit (cfg) diskSize;
  };
in
{
  options.boot.efi = {
    populateRootfs = mkEnableOption (mdDoc "populate the rootfs with the kernel and initramfs");
    diskSize = mkOption {
      type = types.str;
      default = "512M";
      description = mdDoc "The size to allocate for the disk image, auto to automatically allocate.";
    };
    volume = mkOption {
      type = types.str;
      default = "EXPIDUS";
      description = mdDoc "The name of the volume to boot ExpidusOS from";
    };
  };

  config = {
    system.build = {
      inherit efipart;
      refindConfig = pkgs.writeText "refind.conf" ''
        timeout 0

        menuentry "ExpidusOS" {
          icon /EFI/refind/icons/os_linux.png
          ${if cfg.populateRootfs then ''
            volume "${cfg.volume}"
            loader /boot/vmlinuz
            initrd /boot/initramfs.img
          '' else ''
            loader /EFI/expidus/vmlinuz
            initrd /EFI/expidus/initramfs.img
          ''}
          options "${concatMapStrings (x: x + " ") config.boot.kernelParams}"
          ostype Linux
        }
      '';
    };

    system.activationScripts.efi = ''
      mkdir -p /boot/efi
      ${optionalString cfg.populateRootfs ''
        cp ${config.system.build.kernel}/bzImage /boot/vmlinuz
        cp ${config.system.build.initialRamdisk}/initrd /boot/initramfs.img
      ''}
    '';

    boot.initrd = rec {
      availableKernelModules = [ "vfat" "nls_cp437" "nls_ascii" "nls_iso8859_1" ];
      kernelModules = availableKernelModules;
    };
  };
}
