{ config, lib, pkgs, ... }:
with lib;
let
  systemBuilder =
    let
      kernelPath = "${config.boot.kernelPackages.kernel}/" +
        "${config.system.boot.loader.kernelFile}";
    in ''
      mkdir -p $out

      ${optionalString config.boot.kernel.enable ''
        if [ ! -f ${kernelPath} ]; then
          echo "The bootloader cannot find the proper kernel image."
          echo "(Expecting ${kernelPath})"
          false
        fi

        ln -s ${kernelPath} $out/kernel
        ln -s ${config.system.modulesTree} $out/kernel-modules
        echo -n "$kernelParams" > $out/kernel-params

        ln -s ${config.hardware.firmware}/lib/firmware $out/firmware
      ''}

      echo "$activationScript" > $out/activate
      substituteInPlace $out/activate --subst-var out
      chmod u+x $out/activate
      unset activationScript

      ln -s ${config.system.build.etc}/etc $out/etc
      ln -s ${config.system.path} $out/sw

      mkdir $out/bin

      ${config.system.systemBuilderCommands}
      echo -n "$extraDependencies" > $out/extra-dependencies
      ${config.system.extraSystemBuilderCmds}
    '';

  baseSystem = pkgs.stdenvNoCC.mkDerivation ({
    name = "expidus-system";

    preferLocalBuild = true;
    allowSubstitutes = false;
    buildCommand = systemBuilder;

    inherit (pkgs) coreutils;
    systemd = config.systemd.package;
    shell = "${pkgs.bash}/bin/sh";
    su = "${pkgs.shadow.su}/bin/su";
    utillinux = pkgs.util-linux;

    inherit (config.system) extraDependencies;

    kernelParams = config.boot.kernelParams;
    activationScript = config.system.activationScripts.script;
  } // config.system.systemBuilderArgs);

  failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);

  baseSystemAssertWarn = if failedAssertions != []
    then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
    else showWarnings config.warnings baseSystem;

  system = foldr ({ oldDependency, newDependency }: drv:
    pkgs.replaceDependency { inherit oldDependency newDependency drv; }
  ) baseSystemAssertWarn config.system.replaceRuntimeDependencies;
in
{
  options.system = {
    boot.loader = {
      kernelFile = mkOption {
        internal = true;
        default = pkgs.stdenv.hostPlatform.linux-kernel.target;
        defaultText = literalExpression "pkgs.stdenv.hostPlatform.linux-kernel.target";
        type = types.str;
        description = lib.mdDoc ''
          Name of the kernel file to be passed to the bootloader.
        '';
      };
    };

    systemBuilderCommands = mkOption {
      type = types.lines;
      internal = true;
      default = "";
      description = ''
        This code will be added to the builder creating the system store path.
      '';
    };

    systemBuilderArgs = mkOption {
      type = types.attrsOf types.unspecified;
      internal = true;
      default = {};
      description = lib.mdDoc ''
        `lib.mkDerivation` attributes that will be passed to the top level system builder.
      '';
    };

    forbiddenDependenciesRegex = mkOption {
      default = "";
      example = "-dev$";
      type = types.str;
      description = lib.mdDoc ''
        A POSIX Extended Regular Expression that matches store paths that
        should not appear in the system closure, with the exception of {option}`system.extraDependencies`, which is not checked.
      '';
    };

    extraSystemBuilderCmds = mkOption {
      type = types.lines;
      internal = true;
      default = "";
      description = lib.mdDoc ''
        This code will be added to the builder creating the system store path.
      '';
    };

    extraDependencies = mkOption {
      type = types.listOf types.package;
      default = [];
      description = lib.mdDoc ''
        A list of packages that should be included in the system
        closure but not otherwise made available to users. This is
        primarily used by the installation tests.
      '';
    };

    replaceRuntimeDependencies = mkOption {
      default = [];
      example = lib.literalExpression "[ ({ original = pkgs.openssl; replacement = pkgs.callPackage /path/to/openssl { }; }) ]";
      type = types.listOf (types.submodule (
        { ... }: {
          options.original = mkOption {
            type = types.package;
            description = lib.mdDoc "The original package to override.";
          };

          options.replacement = mkOption {
            type = types.package;
            description = lib.mdDoc "The replacement package.";
          };
        })
      );
      apply = map ({ original, replacement, ... }: {
        oldDependency = original;
        newDependency = replacement;
      });
      description = lib.mdDoc ''
        List of packages to override without doing a full rebuild.
        The original derivation and replacement derivation must have the same
        name length, and ideally should have close-to-identical directory layout.
      '';
    };
  };

  config.system = {
    extraSystemBuilderCmds = optionalString (config.system.forbiddenDependenciesRegex != "") ''
      if [[ $forbiddenDependenciesRegex != "" && -n $closureInfo ]]; then
        if forbiddenPaths="$(grep -E -- "$forbiddenDependenciesRegex" $closureInfo/store-paths)"; then
          echo -e "System closure $out contains the following disallowed paths:\n$forbiddenPaths"
          exit 1
        fi
      fi
    '';

    systemBuilderArgs = lib.optionalAttrs (config.system.forbiddenDependenciesRegex != "") {
      inherit (config.system) forbiddenDependenciesRegex;
      closureInfo = pkgs.closureInfo { rootPaths = [
        # override to avoid  infinite recursion (and to allow using extraDependencies to add forbidden dependencies)
        (config.system.build.toplevel.overrideAttrs (_: { extraDependencies = []; closureInfo = null; }))
      ]; };
    };

    build.toplevel = system;
  };
}
