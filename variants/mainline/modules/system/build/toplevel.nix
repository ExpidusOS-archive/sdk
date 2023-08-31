{ config, lib, pkgs, ... }:
with lib;
let
  systemBuilder =
    ''
      mkdir $out

      ${if config.boot.initrd.systemd.enable then ''
        cp ${config.system.build.bootStage2} $out/prepare-root
        substituteInPlace $out/prepare-root --subst-var-by systemConfig $out
        # This must not be a symlink or the abs_path of the grub builder for the tests
        # will resolve the symlink and we end up with a path that doesn't point to a
        # system closure.
        cp "$systemd/lib/systemd/systemd" $out/init
      '' else ''
        cp ${config.system.build.bootStage2} $out/init
        substituteInPlace $out/init --subst-var-by systemConfig $out
      ''}

      ln -s ${config.system.build.etc}/etc $out/etc
      ln -s ${config.system.path} $out/sw
      ln -s "$systemd" $out/systemd

      echo -n "systemd ${toString config.systemd.package.interfaceVersion}" > $out/init-interface-version
      echo -n "${config.boot.kernelPackages.stdenv.hostPlatform.system}" > $out/system

      ${config.system.systemBuilderCommands}

      cp "$extraDependenciesPath" "$out/extra-dependencies"

      ${optionalString (!config.boot.isContainer && config.boot.bootspec.enable) ''
        ${config.boot.bootspec.writer}
        ${optionalString config.boot.bootspec.enableValidation
          ''${config.boot.bootspec.validator} "$out/${config.boot.bootspec.filename}"''}
      ''}

      ${config.system.extraSystemBuilderCmds}
    '';

  baseSystem = pkgs.stdenvNoCC.mkDerivation ({
    name = "expidus-system-${config.system.expidus.label}";

    preferLocalBuild = true;
    allowSubstitutes = false;
    passAsFile = [ "extraDependencies" ];
    buildCommand = systemBuilder;

    inherit (pkgs) coreutils;
    systemd = config.systemd.package;
    shell = "${pkgs.bash}/bin/sh";
    su = "${pkgs.shadow.su}/bin/su";
    utillinux = pkgs.util-linux;

    kernelParams = config.boot.kernelParams;
    #installBootLoader = config.system.build.installBootLoader;
    activationScript = config.system.activationScripts.script;

    inherit (config.system) extraDependencies;

    # Needed by switch-to-configuration.
    perl = pkgs.perl.withPackages (p: with p; [ ConfigIniFiles FileSlurp ]);
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

      initrdFile = mkOption {
        internal = true;
        default = "initrd";
        type = types.str;
        description = lib.mdDoc ''
          Name of the initrd file to be passed to the bootloader.
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

    checks = mkOption {
      type = types.listOf types.package;
      default = [];
      description = lib.mdDoc ''
        Packages that are added as dependencies of the system's build, usually
        for the purpose of validating some part of the configuration.

        Unlike `system.extraDependencies`, these store paths do not
        become part of the built system configuration.
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

    systemBuilderArgs = {
      passedChecks = concatStringsSep " " config.system.checks;
    } // lib.optionalAttrs (config.system.forbiddenDependenciesRegex != "") {
      inherit (config.system) forbiddenDependenciesRegex;
      closureInfo = pkgs.closureInfo { rootPaths = [
        # override to avoid  infinite recursion (and to allow using extraDependencies to add forbidden dependencies)
        (config.system.build.toplevel.overrideAttrs (_: { extraDependencies = []; closureInfo = null; }))
      ]; };
    };

    build.toplevel = system;
  };
}
