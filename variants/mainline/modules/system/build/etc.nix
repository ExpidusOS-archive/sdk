{ config, lib, ... }:
{
  config.system.activationScripts.etc = config.system.build.etcActivationCommands;
}
