{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.boot.loader.efi;
  opts = options.boot.loader.efi;
in {
  options.boot.loader.efi.enable = mkEnableOption "Enables EFI support";

  config = {
    assertions = [{
      assertion = cfg.enable -> !pkgs.targetPlatform.isEFI;
      message = "Cannot enable UEFI suppport while EFI is not supported on the target platform";
    }];
  };
}
