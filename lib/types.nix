{ lib, expidus }:
with lib;
{
  flatpak = {
    runtime = types.submodule ({ config, ... }: {
      options = {
        name = mkOption {
          type = types.str;
          default = config._module.args.name;
        };
        branch = mkOption {
          type = types.str;
          description = "ostree branch";
        };
        commit = mkOption {
          type = types.str;
          description = "ostree commit";
        };
        sha256 = mkOption {
          type = types.str;
          description = "SHA-256 hash sum of the runtime";
        };
      };
    });
    application = types.submodule ({ config, ... }: {
      options = {
        name = mkOption {
          type = types.str;
          default = config._module.args.name;
        };
        commit = mkOption {
          type = types.str;
          description = "ostree commit";
        };
        sha256 = mkOption {
          type = types.str;
          description = "SHA-256 hash sum of the application";
        };
        runtime = mkOption {
          type = types.oneOf [
            types.str
            flatpak.runtime
          ];
          description = "Name of a runtime or a runtime definition";
        };
      };
    });
  };
}
