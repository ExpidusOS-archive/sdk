{ lib, config, pkgs, ... }:
with lib;
{
  options.system.config = mkOption {
    type = types.anything;
    description = mdDoc ''
      System configuration
    '';
    default = {
      hostname = config.networking.hostName;
      locale = config.i18n.defaultLocale;
      timezone = config.time.timeZone or "America/Los_Angeles";
    };
  };

  config = mkIf (pkgs.targetPlatform.isAarch64 == false) {
    system.build.systemConfig = pkgs.writers.writeJSON "expidus-system.json" config.system.config;
    environment.etc."expidus/default-system.json".source = config.system.build.systemConfig;
    environment.systemPackages = with pkgs; [ expidus.config ];
    system.datafs.contents = [
      {
        source = config.system.build.systemConfig;
        target = "config/system.json";
      }
    ];
  };
}
