{ config, lib, pkgs, ... }:
with lib;
let
  inherit (config.boot.kernel) features randstructSeed patches;
  inherit (config.boot.kernel.packages) kernel;

  kernelModulesConf = pkgs.writeText "expidus.conf" ''
    ${concatStringsSep "\n" config.boot.kernel.modules}
  '';
in
{
  options = {
    boot = {
      kernel = {
        enable = mkEnableOption (mdDoc "the Linux kernel. This is useful for systemd-like containers which do not require a kernel") // {
          default = true;
        };

        features = mkOption {
          default = {};
          example = literalExpression "{ debug = true; }";
          internal = true;
          description = mdDoc ''
            This option allows to enable or disable certain kernel features.
          '';
        };

        packages = mkOption {
          default = pkgs.linuxPackages;
          type = types.raw;
          apply = kernelPackages: kernelPackages.extend (self: super: {
            kernel = super.kernel.override (originalArgs: {
              inherit randstructSeed;
              kernelPatches = (originalArgs.kernelPatches or []) ++ patches;
              features = lrecursiveUpdate super.kernel.features features;
            });
          });
          defaultText = literalExpression "pkgs.linuxPackages";
          example = literalExpression "pkgs.linuxKernel.packages.linux_5_10";
          description = mdDoc ''
            This option allows you to override the Linux kernel used by
            ExpidusOS.
          '';
        };

        patches = mkOption {
          type = with types; listOf attrs;
          default = [];
          example = literalExpression ''
            [
              {
                name = "foo";
                patch = ./foo.patch;
                extraStructuredConfig.FOO = lib.kernel.yes;
                features.foo = true;
              }
            ]
          '';
           description = mdDoc ''
            A list of patches to apply to the kernel.
          '';
        };

        randstructSeed = mkOption {
          type = types.str;
          default = "";
          example = "my secret seed";
          description = mdDoc ''
            Provides a custom seed for the {var}`RANDSTRUCT` security
            option of the Linux kernel.
          '';
        };

        params = mkOption {
          type = with types; listOf (strMatching ''([^"[:space:]]|"[^"]*")+'' // {
            name = "kernelParam";
            description = "string, with spaces inside double quotes";
          });
          default = [];
          description = mdDoc "Parameters added to the kernel command line.";
        };

        modules = mkOption {
          type = with types; listOf str;
          default = [];
          description = mdDoc ''
            The set of kernel modules to be loaded in the second stage of
            the boot process.  Note that modules that are needed to
            mount the root file system should be added to
            {option}`boot.initrd.availableKernelModules` or
            {option}`boot.initrd.kernelModules`.
          '';
        };
      };

      initrd = {
        availableKernelModules = mkOption {
          type = with types; listOf str;
          default = [];
          example = [ "sata_nv" "ext3" ];
          description = mdDoc ''
            The set of kernel modules in the initial ramdisk used during the
            boot process.  This set must include all modules necessary for
            mounting the root device.  That is, it should include modules
            for the physical device (e.g., SCSI drivers) and for the file
            system (e.g., ext3).  The set specified here is automatically
            closed under the module dependency relation, i.e., all
            dependencies of the modules list here are included
            automatically.  The modules listed here are available in the
            initrd, but are only loaded on demand (e.g., the ext3 module is
            loaded automatically when an ext3 filesystem is mounted, and
            modules for PCI devices are loaded when they match the PCI ID
            of a device in your system).  To force a module to be loaded,
            include it in {option}`boot.initrd.kernelModules`.
          '';
        };

        kernelModules = mkOption {
          type = with types; listOf str;
          default = [];
          description = mdDoc "List of modules that are always loaded by the initrd.";
        };

        includeDefaultModules = mkOption {
          type = types.bool;
          default = true;
          description = mdDoc ''
            This option, if set, adds a collection of default kernel modules
            to {option}`boot.initrd.availableKernelModules` and
            {option}`boot.initrd.kernelModules`.
          '';
        };
      };
    };

    system = {
      modulesTree = mkOption {
        type = with types; listOf path;
        internal = true;
        default = [];
        description = mdDoc ''
          Tree of kernel modules.  This includes the kernel, plus modules
          built outside of the kernel.  Combine these into a single tree of
          symlinks because modprobe only supports one directory.
        '';
        apply = pkgs.aggregateModules;
      };

      requiredKernelConfig = mkOption {
        default = [];
        example = literalExpression ''
          with config.lib.kernelConfig; [
            (isYes "MODULES")
            (isEnabled "FB_CON_DECOR")
            (isEnabled "BLK_DEV_INITRD")
          ]
        '';
        internal = true;
        type = with types; listOf attrs;
        description = mdDoc ''
          This option allows modules to specify the kernel config options that
          must be set (or unset) for the module to work. Please use the
          lib.kernelConfig functions to build list elements.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf config.boot.kernel.enable {
      system = {
        build = {
          inherit kernel;
        };
        requiredKernelConfig = with config.lib.kernelConfig; [
          (isYes "MODULES")
          (isYes "BINFMT_ELF")
        ] ++ (optional (randstructSeed != "") (isYes "GCC_PLUGIN_RANDSTRUCT"));
      };

      boot.kernel.modules = [ "loop" "atkbd" ];

      environment.etc."modules-load.d/expidus.conf".source = kernelModulesConf;

      lib.kernelConfig = {
        isYes = option: {
          assertion = config: config.isYes option;
          message = "CONFIG_${option} is not yes!";
          configLine = "CONFIG_${option}=y";
        };

        isNo = option: {
          assertion = config: config.isNo option;
          message = "CONFIG_${option} is not no!";
          configLine = "CONFIG_${option}=n";
        };

        isModule = option: {
          assertion = config: config.isModule option;
          message = "CONFIG_${option} is not built as a module!";
          configLine = "CONFIG_${option}=m";
        };

        ### Usually you will just want to use these two
        # True if yes or module
        isEnabled = option: {
          assertion = config: config.isEnabled option;
          message = "CONFIG_${option} is not enabled!";
          configLine = "CONFIG_${option}=y";
        };

        # True if no or omitted
        isDisabled = option: {
          assertion = config: config.isDisabled option;
          message = "CONFIG_${option} is not disabled!";
          configLine = "CONFIG_${option}=n";
        };
      };

      assertions = if config.boot.kernel.packages.kernel ? features then []
        else
          let
            cfg = config.boot.kernel.packages.kernel.config;
          in map (attrs: {
            assertion = attrs.assertion cfg;
            inherit (attrs) message;
          }) config.system.requiredKernelConfig;
    })
  ];
}
