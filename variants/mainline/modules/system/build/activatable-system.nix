{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkOption
    optionalString
    types
    ;

  perlWrapped = pkgs.perl.withPackages (p: with p; [ ConfigIniFiles FileSlurp ]);

  systemBuilderArgs = {
    activationScript = config.system.activationScripts.script;
  };

  systemBuilderCommands = ''
    echo "$activationScript" > $out/activate
    substituteInPlace $out/activate --subst-var-by out ''${!toplevelVar}
    chmod u+x $out/activate
    unset activationScript
  '';

in
{
  options = {
    system.activatable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to add the activation script to the system profile.

        The default, to have the script available all the time, is what we normally
        do, but for image based systems, this may not be needed or not be desirable.
      '';
    };
    system.build.separateActivationScript = mkOption {
      type = types.package;
      description = ''
        A separate activation script package that's not part of the system profile.

        This is useful for configurations where `system.activatable` is `false`.
        Otherwise, you can just use `system.build.toplevel`.
      '';
    };
  };
  config = {
    system.systemBuilderCommands = lib.mkIf config.system.activatable systemBuilderCommands;
    system.systemBuilderArgs = lib.mkIf config.system.activatable
      (systemBuilderArgs // {
        toplevelVar = "out";
      });

    system.build.separateActivationScript =
      pkgs.runCommand
        "separate-activation-script"
        (systemBuilderArgs // {
          toplevelVar = "toplevel";
          toplevel = config.system.build.toplevel;
        })
        ''
          mkdir $out
          ${systemBuilderCommands}
        '';
  };
}
