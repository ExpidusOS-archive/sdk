args@{ lib, config, pkgs, ... }:
with lib;
let
  base = import ("${lib.expidus.channels.nixpkgs}/nixos/modules/virtualisation/lxc-container.nix") args;
  templateSubmodule = { ... }: {
    options = {
      enable = mkEnableOption "this template";

      target = mkOption {
        description = "Path in the container";
        type = types.path;
      };
      template = mkOption {
        description = ".tpl file for rendering the target";
        type = types.path;
      };
      when = mkOption {
        description = "Events which trigger a rewrite (create, copy)";
        type = types.listOf (types.str);
      };
      properties = mkOption {
        description = "Additional properties";
        type = types.attrs;
        default = {};
      };
    };
  };

  toYAML = name: data: pkgs.writeText name (generators.toYAML {} data);

  cfg = config.virtualisation.lxc;
  templates = if cfg.templates != {} then let
    list = mapAttrsToList (name: value: { inherit name; } // value)
      (filterAttrs (name: value: value.enable) cfg.templates);
  in
    {
      files = map (tpl: {
        source = tpl.template;
        target = "/templates/${tpl.name}.tpl";
      }) list;
      properties = listToAttrs (map (tpl: nameValuePair tpl.target {
        when = tpl.when;
        template = "${tpl.name}.tpl";
        properties = tpl.properties;
      }) list);
    }
  else { files = []; properties = {}; };
in {
  inherit (base) imports options;

  config = {
    inherit (base.config) boot systemd users services;

    system = {
      inherit (base.config.system) activationScripts;

      build.metadata = pkgs.callPackage ../../lib/make-system-tarball.nix {
        contents = [{
          source = toYAML "metadata.yaml" {
            architecture = builtins.elemAt (builtins.match "^([a-z0-9_]+).+" (toString pkgs.system)) 0;
            creation_date = 1;
            properties = {
              description = "NixOS ${config.system.nixos.codeName} ${config.system.nixos.label} ${pkgs.system}";
              os = "nixos";
              release = "${config.system.nixos.codeName}";
            };
            templates = templates.properties;
          };
          target = "/metadata.yaml";
        }] ++ templates.files;
      };

      # TODO: build rootfs as squashfs for faster unpack
      build.tarball = pkgs.callPackage ../../lib/make-system-tarball.nix {
        extraArgs = "--owner=0";
        storeContents = [{
          object = config.system.build.toplevel;
          symlink = "none";
        }];
        contents = [{
          source = config.system.build.toplevel + "/init";
          target = "/sbin/init";
        }];
        extraCommands = "mkdir -p proc sys dev";
      };
    };
  };
}
