{ config, lib, pkgs, ... }:
with lib;
{
  options.services.xserver = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable the X server.
      '';
    };

    videoDrivers = mkOption {
      type = types.listOf types.str;
      default = [ "modesetting" "fbdev" ];
      example = [
        "nvidia" "nvidiaLegacy390" "nvidiaLegacy340" "nvidiaLegacy304"
        "amdgpu-pro"
      ];
      # TODO(@oxij): think how to easily add the rest, like those nvidia things
      relatedPackages = concatLists
        (mapAttrsToList (n: v:
          optional (hasPrefix "xf86video" n) {
            path  = [ "xorg" n ];
            title = removePrefix "xf86video" n;
          }) pkgs.xorg);
      description = lib.mdDoc ''
        The names of the video drivers the configuration
        supports. They will be tried in order until one that
        supports your card is found.
        Don't combine those with "incompatible" OpenGL implementations,
        e.g. free ones (mesa-based) with proprietary ones.

        For unfree "nvidia*", the supported GPU lists are on
        https://www.nvidia.com/object/unix.html
      '';
    };
  };
}
