{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.expidus;
  opts = options.expidus;
in {
  config = {
    boot.binfmt.emulatedSystems = lib.lists.subtractLists lib.platforms.cygwin (lib.filter (sys: sys != pkgs.system) (lib.expidus.system.supported ++ [
      "i686-windows"
      "x86_64-windows"
    ]));

    boot.plymouth.enable = mkDefault true;

    services.hercules-ci-agent.settings.labels.expidus =
      let
        mkIfNotNull = x: mkIf (x != null) x;
      in {
        configurationRevision = mkIfNotNull config.system.configurationRevision;
        inherit (config.system.expidus) release codeName tags;
        label = mkIfNotNull config.system.expidus.label;
        systemName = mkIfNotNull config.system.name;
      };

    services.upower = {
      enable = mkDefault true;
      criticalPowerAction = mkDefault "PowerOff";
      percentageLow = mkDefault 20;
      percentageCritical = mkDefault 10;
      percentageAction = mkDefault 5;
    };

    services.logind = {
      lidSwitch = mkDefault "hybrid-sleep";
      lidSwitchDocked = mkDefault "lock";
      lidSwitchExternalPower = mkDefault "lock";
    };
  };
}
