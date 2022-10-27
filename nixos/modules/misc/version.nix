args@{ config, lib, options, pkgs, ... }:
with lib;
let
  base = import ((import ../../../lib/nixpkgs.nix) + "/nixos/modules/misc/version.nix") args;
  cfg = config.expidus;
in base // {
  options.system = base.options.system // {
    defaultChannel = mkOption {
      internal = true;
      type = types.str;
      default = "https://github.com/ExpidusOS/sdk/archive/refs/heads/master.tar.gz";
      description = "Default NixOS channel to which the root user is subscribed.";
    };
  };

  config = base.config // {
    environment.etc = {
      "lsb-release".source = "${pkgs.expidus-sdk.system}/etc/lsb-release";
      "os-release".source = "${pkgs.expidus-sdk.system}/etc/os-release";
    };
  };
}
