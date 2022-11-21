{ lib, config, ... }:
pkgs: super:
with pkgs;
rec {
  nixos = configuration:
    let
      c = import ../../nixos/lib/eval-config.nix {
        inherit (stdenv.hostPlatform) system;
        pkgs = pkgs;
        inherit lib;
        modules = [({ lib, ... }: {
          config.nixpkgs.pkgs = lib.mkDefault pkgs;
        })] ++ (if builtins.isList configuration then
          configuration
        else [configuration]);
      };
    in c.config.system.build // c;

  nixosOptionsDoc = attrs:
    (import ../../nixos/lib/make-options-doc)
      ({ inherit lib pkgs; } // attrs);
}
