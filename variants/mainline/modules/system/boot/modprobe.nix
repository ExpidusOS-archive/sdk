{ config, lib, pkgs, ... }:
with lib;
{
  options.boot = {
    modprobeConfig.enable = mkEnableOption (mdDoc "modprobe config. This is useful for systemds like containers which do not require a kernel.") // {
      default = true;
    };

    blacklistedKernelModules = mkOption {
      type = with types; listOf str;
      default = [];
      example = [ "cirrusfb" "i2c_piix4" ];
      description = mdDoc ''
        List of names of kernel modules that should not be loaded
        automatically by the hardware probing code.
      '';
    };

    extraModprobeConfig = mkOption {
      default = "";
      example = ''
        options parport_pc io=0x378 irq=7 dma=1
      '';
      description = mdDoc ''
        Any additional configuration to be appended to the generated
        {file}`modprobe.conf`.  This is typically used to
        specify module options.  See
        {manpage}`modprobe.d(5)` for details.
      '';
      type = types.lines;
    };
  };

  config = mkIf config.boot.modprobeConfig.enable {
    environment = {
      etc = {
        "modprobe.d/debian.conf".source = pkgs.kmod-debian-aliases;
        "modprobe.d/systemd.conf".source = "${config.systemd.package}/lib/modprobe.d/systemd.conf";
        "modprobe.d/ubuntu.conf".source = "${pkgs.kmod-blacklist-ubuntu}/modprobe.conf";
        "modprobe.d/expidus.conf".text = ''
          ${flip concatMapStrings config.boot.blacklistedKernelModules (name: ''
            blacklist ${name}
          '')}
          ${config.boot.extraModprobeConfig}
        '';
      };
      systemPackages = [ pkgs.kmod ];
    };
  };
}
