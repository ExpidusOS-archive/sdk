let
  lib = import ../lib;
  pkgsConfig = {
    allowUnfree = true;
    allowBroken = true;
    allowUnfreePredicate = _: true;
    allowInsecurePredicate = _: true;
    inHydra = true;
    permittedInsecurePackages = [
      "cockroach"
      "nodejs-12.22.12"
      "n8n"
      "solr-8.6.3"
      "python3.9-flower-1.0.0"
    ];
  };
in with lib;
{ nixpkgs ? { outPath = cleanSource ./..; revCount = 130979; shortRev = "gfedcba"; },
  stableBranch ? false,
  supportedSystems ? lib.expidus.system.supported,
  configuration ? {} }:
with import ("${expidus.channels.nixpkgs}/pkgs/top-level/release-lib.nix") {
  inherit supportedSystems;
  packageSet = import ../.;
  nixpkgsArgs = { config = pkgsConfig; };
};
let
  version = fileContents ../.version;
  versionSuffix =
    (if stableBranch then "." else "-alpha") + "${toString (nixpkgs.revCount - 379959)}.${nixpkgs.shortRev}";
  allTestsForSystem = system:
    import ("${expidus.channels.nixpkgs}/nixos/tests/all-tests.nix") {
      inherit system;
      pkgs = import ./.. { inherit system; config = pkgsConfig; };
      callTest = t: {
        ${system} = hydraJob t.test;
      };
    };
  allTests =
    foldAttrs recursiveUpdate {} (map allTestsForSystem supportedSystems);

  pkgs = import ./.. {
    system = "x86_64-linux";
    config = pkgsConfig;
  };

  versionModule =
    { system.expidus.versionSuffix = versionSuffix;
      system.expidus.revision = nixpkgs.rev or nixpkgs.shortRev;
    };

  makeModules = module: rest: [ configuration versionModule module rest ];

  makeIso =
    { module, type, system, ... }:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        crossSystem.system = system;
        config = pkgsConfig;
      };
      modules = makeModules module {
        isoImage.isoBaseName = "expidus-${type}";
      };
    }).config.system.build.isoImage);


  makeSdImage =
    { module, system, ... }:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        crossSystem.system = system;
        config = pkgsConfig;
      };
      modules = makeModules module {};
    }).config.system.build.sdImage);


  makeSystemTarball =
    { module, maintainers ? ["viric"], system }:
    with import ./.. { inherit system; config = pkgsConfig; };
    let
      config = (import lib/eval-config.nix {
        inherit system;
        pkgs = import ../. {
          crossSystem.system = system;
          config = pkgsConfig;
        };
        modules = makeModules module {};
      }).config;
      tarball = config.system.build.tarball;
    in tarball // {
      meta = {
        description = "ExpidusOS system tarball for ${system} - ${stdenv.hostPlatform.linux-kernel.name}";
        maintainers = map (x: lib.maintainers.${x}) maintainers;
      };
      inherit config;
    };

  makeClosure = module: buildFromConfig module (config: config.system.build.toplevel);

  buildFromConfig = module: sel: forAllSystems (system: hydraJob (sel (import ./lib/eval-config.nix {
    inherit system;
    pkgs = import ../. {
      crossSystem.system = system;
      config = pkgsConfig;
    };
    modules = makeModules module
      ({ ... }:
      { fileSystems."/".device  = mkDefault "/dev/sda1";
        boot.loader.grub.device = mkDefault "/dev/sda";
      });
  }).config));

  makeNetboot = { module, system, ... }:
    let
      configEvaled = import lib/eval-config.nix {
        inherit system;
        pkgs = import ../. {
          crossSystem.system = system;
          config = pkgsConfig;
        };
        modules = makeModules module {};
      };
      build = configEvaled.config.system.build;
      kernelTarget = configEvaled.pkgs.stdenv.hostPlatform.linux-kernel.target;
    in pkgs.symlinkJoin {
      name = "netboot";
      paths = [
        build.netbootRamdisk
        build.kernel
        build.netbootIpxeScript
      ];
      postBuild = ''
        mkdir -p $out/nix-support
        echo "file ${kernelTarget} ${build.kernel}/${kernelTarget}" >> $out/nix-support/hydra-build-products
        echo "file initrd ${build.netbootRamdisk}/initrd" >> $out/nix-support/hydra-build-products
        echo "file ipxe ${build.netbootIpxeScript}/netboot.ipxe" >> $out/nix-support/hydra-build-products
      '';
      preferLocalBuild = true;
    };
in rec {
  channel = import lib/make-channel.nix { inherit pkgs nixpkgs version versionSuffix; };
  manualHTML = buildFromConfig ({ ... }: { }) (config: config.system.build.manual.manualHTML);
  manual = manualHTML; # TODO(@oxij): remove eventually
  manualEpub = (buildFromConfig ({ ... }: { }) (config: config.system.build.manual.manualEpub));
  manpages = buildFromConfig ({ ... }: { }) (config: config.system.build.manual.manpages);
  manualGeneratedSources = buildFromConfig ({ ... }: { }) (config: config.system.build.manual.generatedSources);
  options = (buildFromConfig ({ ... }: { }) (config: config.system.build.manual.optionsJSON)).x86_64-linux;

  # Build the initial ramdisk so Hydra can keep track of its size over time.
  initialRamdisk = buildFromConfig ({ ... }: { }) (config: config.system.build.initialRamdisk);

  netboot = forMatchingSystems supportedSystems (system: makeNetboot {
    module = "${expidus.channels.nixpkgs}/nixos/modules/installer/netboot/netboot-minimal.nix";
    inherit system;
  });

  iso_minimal = forAllSystems (system: makeIso {
    module = ./modules/installer/cd-dvd/installation-cd-minimal.nix;
    type = "minimal";
    inherit system;
  });

  iso_plasma5 = forMatchingSystems [ "x86_64-linux" ] (system: makeIso {
    module = ./modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix;
    type = "plasma5";
    inherit system;
  });

  iso_gnome = forMatchingSystems [ "x86_64-linux" ] (system: makeIso {
    module = ./modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix;
    type = "gnome";
    inherit system;
  });

  iso_genesis = forMatchingSystems [ "x86_64-linux" ] (system: makeIso {
    module = ./modules/installer/cd-dvd/installation-cd-graphical-calamares-genesis.nix;
    type = "genesis";
    inherit system;
  });

  # A variant with a more recent (but possibly less stable) kernel
  # that might support more hardware.
  iso_minimal_new_kernel = forMatchingSystems [ "x86_64-linux" "aarch64-linux" ] (system: makeIso {
    module = ./modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix;
    type = "minimal-new-kernel";
    inherit system;
  });

  sd_image = forMatchingSystems [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ] (system: makeSdImage {
    module = {
        armv6l-linux = "${expidus.channels.nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi-installer.nix";
        armv7l-linux = "${expidus.channels.nixpkgs}/nixos/modules/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix";
        aarch64-linux = "${expidus.channels.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix";
      }.${system};
    inherit system;
  });

  sd_image_new_kernel = forMatchingSystems [ "aarch64-linux" ] (system: makeSdImage {
    module = {
        aarch64-linux = "${expidus.channels.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-installer.nix";
      }.${system};
    type = "minimal-new-kernel";
    inherit system;
  });

  # A bootable VirtualBox virtual appliance as an OVA file (i.e. packaged OVF).
  ova = forMatchingSystems [ "x86_64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules =
        [ versionModule
          ./modules/installer/virtualbox-demo.nix
        ];
    }).config.system.build.virtualBoxOVA)

  );

  # KVM image for proxmox in VMA format
  proxmoxImage = forMatchingSystems [ "x86_64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules = [
        ("${expidus.channels.nixpkgs}/nixos/modules/virtualisation/proxmox-image.nix")
      ];
    }).config.system.build.VMA)
  );

  # LXC tarball for proxmox
  proxmoxLXC = forMatchingSystems [ "x86_64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules = [
        ("${expidus.channels.nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix")
      ];
    }).config.system.build.tarball)
  );

  # A disk image that can be imported to Amazon EC2 and registered as an AMI
  amazonImage = forMatchingSystems [ "x86_64-linux" "aarch64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules =
        [ configuration
          versionModule
          ("${expidus.channels.nixpkgs}/nixos/maintainers/scripts/ec2/amazon-image.nix")
        ];
    }).config.system.build.amazonImage)

  );
  amazonImageZfs = forMatchingSystems [ "x86_64-linux" "aarch64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules =
        [ configuration
          versionModule
          ("${expidus.channels.nixpkgs}/nixos/maintainers/scripts/ec2/amazon-image-zfs.nix")
        ];
    }).config.system.build.amazonImage)
  );

  # Test job for https://github.com/NixOS/nixpkgs/issues/121354 to test
  # automatic sizing without blocking the channel.
  amazonImageAutomaticSize = forMatchingSystems [ "x86_64-linux" "aarch64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules =
        [ configuration
          versionModule
          ("${expidus.channels.nixpkgs}/nixos/maintainers/scripts/ec2/amazon-image.nix")
          ({ ... }: { amazonImage.sizeMB = "auto"; })
        ];
    }).config.system.build.amazonImage)

  );

  # An image that can be imported into lxd and used for container creation
  lxdImage = forMatchingSystems [ "x86_64-linux" "aarch64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules =
        [ configuration
          versionModule
          ("${expidus.channels.nixpkgs}/nixos/maintainers/scripts/lxd/lxd-image.nix")
        ];
    }).config.system.build.tarball)

  );

  # Metadata for the lxd image
  lxdMeta = forMatchingSystems [ "x86_64-linux" "aarch64-linux" ] (system:
    with import ./.. { inherit system; config = pkgsConfig; };
    hydraJob ((import lib/eval-config.nix {
      inherit system;
      pkgs = import ../. {
        inherit system;
        config = pkgsConfig;
      };
      modules =
        [ configuration
          versionModule
          ("${expidus.channels.nixpkgs}/nixos/maintainers/scripts/lxd/lxd-image.nix")
        ];
    }).config.system.build.metadata)
  );

  # Ensure that all packages used by the minimal NixOS config end up in the channel.
  dummy = forAllSystems (system: pkgs.runCommand "dummy"
    { toplevel = (import lib/eval-config.nix {
        inherit system;
        pkgs = import ../. {
          inherit system;
          config = pkgsConfig;
        };
        modules = singleton ({ ... }:
          { fileSystems."/".device  = mkDefault "/dev/sda1";
            boot.loader.grub.device = mkDefault "/dev/sda";
            system.stateVersion = mkDefault "18.03";
          });
      }).config.system.build.toplevel;
      preferLocalBuild = true;
    } "mkdir $out; ln -s $toplevel $out/dummy");


  # Provide a tarball that can be unpacked into an SD card, and easily
  # boot that system from uboot (like for the sheevaplug).
  # The pc variant helps preparing the expression for the system tarball
  # in a machine faster than the sheevpalug
  /*
  system_tarball_pc = forAllSystems (system: makeSystemTarball {
    module = ./modules/installer/cd-dvd/system-tarball-pc.nix;
    inherit system;
  });
  */

  # Provide container tarball for lxc, libvirt-lxc, docker-lxc, ...
  containerTarball = forAllSystems (system: makeSystemTarball {
    module = ./modules/virtualisation/lxc-container.nix;
    inherit system;
  });

  /*
  system_tarball_fuloong2f =
    assert builtins.currentSystem == "mips64-linux";
    makeSystemTarball {
      module = ./modules/installer/cd-dvd/system-tarball-fuloong2f.nix;
      system = "mips64-linux";
    };
  system_tarball_sheevaplug =
    assert builtins.currentSystem == "armv5tel-linux";
    makeSystemTarball {
      module = ./modules/installer/cd-dvd/system-tarball-sheevaplug.nix;
      system = "armv5tel-linux";
    };
  */

  tests = allTests;

  /* Build a bunch of typical closures so that Hydra can keep track of
     the evolution of closure sizes. */

  closures = {
    smallContainer = makeClosure ({ ... }:
      { boot.isContainer = true;
        services.openssh.enable = true;
      });

    tinyContainer = makeClosure ({ ... }:
      { boot.isContainer = true;
        imports = [ ("${expidus.channels.nixpkgs}/nixos/modules/profiles/minimal.nix") ];
      });

    ec2 = makeClosure ({ ... }:
      { imports = [ ("${expidus.channels.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix") ];
      });

    kde = makeClosure ({ ... }:
      { services.xserver.enable = true;
        services.xserver.displayManager.sddm.enable = true;
        services.xserver.desktopManager.plasma5.enable = true;
      });

    xfce = makeClosure ({ ... }:
      { services.xserver.enable = true;
        services.xserver.desktopManager.xfce.enable = true;
      });

    gnome = makeClosure ({ ... }:
      { services.xserver.enable = true;
        services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;
      });

    pantheon = makeClosure ({ ... }:
      { services.xserver.enable = true;
        services.xserver.desktopManager.pantheon.enable = true;
      });

    # Linux/Apache/PostgreSQL/PHP stack.
    lapp = makeClosure ({ pkgs, ... }:
      { services.httpd.enable = true;
        services.httpd.adminAddr = "foo@example.org";
        services.httpd.enablePHP = true;
        services.postgresql.enable = true;
        services.postgresql.package = pkgs.postgresql;
      });
  };
}
