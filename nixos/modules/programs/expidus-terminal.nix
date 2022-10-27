{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.expidus-terminal;
in {
  meta = {
    maintainers = pkgs.expidus-terminal.meta.maintainers;
  };

  options = {
    programs.expidus-terminal.enable = mkEnableOption "ExpidusOS Terminal";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.expidus-terminal ];
    services.dbus.packages = [ pkgs.expidus-terminal ];
    systemd.packages = [ pkgs.expidus-terminal ];

    programs.bash.vteIntegration = true;
    programs.zsh.vteIntegration = true;
  };
}
