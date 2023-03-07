{ config, lib, pkgs, utils, ... }:
with lib;
let
  udev = config.systemd.package;
  kernel-name = config.boot.kernelPackages.kernel.name or "kernel";
  modulesTree = config.system.modulesTree.override { name = kernel-name + "-modules"; };
  firmware = config.hardware.firmware;

  modulesClosure = pkgs.makeModulesClosure {
    rootModules = config.boot.initrd.availableKernelModules ++ config.boot.initrd.kernelModules;
    kernel = modulesTree;
    firmware = firmware;
    allowMissing = false;
  };

  fileSystems = filter utils.fsNeededForBoot config.system.build.fileSystems;
  zfsRequiresMountHelper = any (fs: lib.elem "zfsutil" fs.options) fileSystems;

  findLibs = pkgs.buildPackages.writeShellScriptBin "find-libs" ''
    set -euo pipefail

    declare -A seen
    left=()

    patchelf="${pkgs.buildPackages.patchelf}/bin/patchelf"

    function add_needed {
      rpath="$($patchelf --print-rpath $1)"
      dir="$(dirname $1)"
      for lib in $($patchelf --print-needed $1); do
        left+=("$lib" "$rpath" "$dir")
      done
    }

    add_needed "$1"

    while [ ''${#left[@]} -ne 0 ]; do
      next=''${left[0]}
      rpath=''${left[1]}
      ORIGIN=''${left[2]}
      left=("''${left[@]:3}")

      if [ -z ''${seen[$next]+x} ]; then
        seen[$next]=1

        # Ignore the dynamic linker which for some reason appears as a DT_NEEDED of glibc but isn't in glibc's RPATH.
        case "$next" in
          ld*.so.?) continue;;
        esac

        IFS=: read -ra paths <<< $rpath
        res=
        for path in "''${paths[@]}"; do
          path=$(eval "echo $path")
          if [ -f "$path/$next" ]; then
              res="$path/$next"
              echo "$res"
              add_needed "$res"
              break
          fi
        done

        if [ -z "$res" ]; then
          echo "Couldn't satisfy dependency $next" >&2
          exit 1
        fi
      fi
    done
  '';

  extraUtils = pkgs.runCommandCC "extra-utils"
    { nativeBuildInputs = [pkgs.buildPackages.nukeReferences];
      allowedReferences = [ "out" ]; # prevent accidents like glibc being included in the initrd
    }
    ''
      set +o pipefail

      mkdir -p $out/bin $out/lib
      ln -s $out/bin $out/sbin

      copy_bin_and_libs () {
        [ -f "$out/bin/$(basename $1)" ] && rm "$out/bin/$(basename $1)"
        cp -pdv $1 $out/bin
      }

      # Copy BusyBox.
      for BIN in ${pkgs.busybox}/{s,}bin/*; do
        copy_bin_and_libs $BIN
      done

      ${optionalString zfsRequiresMountHelper ''
        # Filesystems using the "zfsutil" option are mounted regardless of the
        # mount.zfs(8) helper, but it is required to ensure that ZFS properties
        # are used as mount options.
        #
        # BusyBox does not use the ZFS helper in the first place.
        # util-linux searches /sbin/ as last path for helpers (stage-1-init.sh
        # must symlink it to the store PATH).
        # Without helper program, both `mount`s silently fails back to internal
        # code, using default options and effectively ignore security relevant
        # ZFS properties such as `setuid=off` and `exec=off` (unless manually
        # duplicated in `fileSystems.*.options`, defeating "zfsutil"'s purpose).
        copy_bin_and_libs ${pkgs.util-linux}/bin/mount
        copy_bin_and_libs ${pkgs.zfs}/bin/mount.zfs
      ''}

      # Copy some util-linux stuff.
      copy_bin_and_libs ${pkgs.util-linux}/sbin/blkid

      # Copy dmsetup and lvm.
      copy_bin_and_libs ${getBin pkgs.lvm2}/bin/dmsetup
      copy_bin_and_libs ${getBin pkgs.lvm2}/bin/lvm

      # Add RAID mdadm tool.
      copy_bin_and_libs ${pkgs.mdadm}/sbin/mdadm
      copy_bin_and_libs ${pkgs.mdadm}/sbin/mdmon

      # Copy udev.
      copy_bin_and_libs ${udev}/bin/udevadm
      copy_bin_and_libs ${udev}/lib/systemd/systemd-sysctl

      for BIN in ${udev}/lib/udev/*_id; do
        copy_bin_and_libs $BIN
      done

      # systemd-udevd is only a symlink to udevadm these days
      ln -sf udevadm $out/bin/systemd-udevd

      # Copy modprobe.
      copy_bin_and_libs ${pkgs.kmod}/bin/kmod
      ln -sf kmod $out/bin/modprobe

      cat >$out/bin/modprobe-kernel <<EOF
      #!$out/bin/ash
      export LD_LIBRARY_PATH=$out/lib
      exec $out/bin/modprobe "\$@"
      EOF

      chmod +x $out/bin/modprobe-kernel

      ${optionalString (any (fs: fs.autoResize && (lib.hasPrefix "ext" fs.fsType)) fileSystems) ''
        # We need mke2fs in the initrd.
        copy_bin_and_libs ${pkgs.e2fsprogs}/sbin/resize2fs
      ''}

      # Copy multipath.
      ${optionalString config.services.multipath.enable ''
        copy_bin_and_libs ${config.services.multipath.package}/bin/multipath
        copy_bin_and_libs ${config.services.multipath.package}/bin/multipathd

        # Copy lib/multipath manually.
        cp -rpv ${config.services.multipath.package}/lib/multipath $out/lib
      ''}

      ${config.boot.initrd.extraUtilsCommands}

      cp -pv ${pkgs.stdenv.cc.libc.out}/lib/ld*.so.? $out/lib

      # Copy all of the needed libraries
      find $out/bin $out/lib -type f | while read BIN; do
        echo "Copying libs for executable $BIN"
        for LIB in $(${findLibs}/bin/find-libs $BIN); do
          TGT="$out/lib/$(basename $LIB)"
          if [ ! -f "$TGT" ]; then
            SRC="$(readlink -e $LIB)"
            cp -pdv "$SRC" "$TGT"
          fi
        done
      done

      # Strip binaries further than normal.
      chmod -R u+w $out
      stripDirs "$STRIP" "$RANLIB" "lib bin" "-s"

      # Run patchelf to make the programs refer to the copied libraries.
      find $out/bin $out/lib -type f | while read i; do
        nuke-refs -e $out $i
      done

      find $out/bin -type f | while read i; do
        echo "patching $i..."
        patchelf --set-interpreter $out/lib/ld*.so.? --set-rpath $out/lib $i || true
      done

      find $out/lib -type f \! -name 'ld*.so.?' | while read i; do
        echo "patching $i..."
        patchelf --set-rpath $out/lib $i
      done

      if [ -z "${toString (pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform)}" ]; then
      # Make sure that the patchelf'ed binaries still work.
      echo "testing patched programs..."
      $out/bin/ash -c 'echo hello world' | grep "hello world"

      ${if zfsRequiresMountHelper then ''
        $out/bin/mount -V 1>&1 | grep -q "mount from util-linux"
        $out/bin/mount.zfs -h 2>&1 | grep -q "Usage: mount.zfs"
      '' else ''
        $out/bin/mount --help 2>&1 | grep -q "BusyBox"
      ''}

      $out/bin/blkid -V 2>&1 | grep -q 'libblkid'
      $out/bin/udevadm --version
      $out/bin/dmsetup --version 2>&1 | tee -a log | grep -q "version:"

      LVM_SYSTEM_DIR=$out $out/bin/lvm version 2>&1 | tee -a log | grep -q "LVM"
      $out/bin/mdadm --version

      ${optionalString config.services.multipath.enable ''
        ($out/bin/multipath || true) 2>&1 | grep -q 'need to be root'
        ($out/bin/multipathd || true) 2>&1 | grep -q 'need to be root'
      ''}

      ${config.boot.initrd.extraUtilsCommandsTest}
      fi
    '';

  linkUnits = pkgs.runCommand "link-units" {
    allowedReferences = [ extraUtils ];
    preferLocalBuild = true;
  } (''
    mkdir -p $out
    cp -v ${udev}/lib/systemd/network/*.link $out/
  '' + (
    let
      links = filterAttrs (n: v: hasSuffix ".link" n) config.systemd.network.units;
      files = mapAttrsToList (n: v: "${v.unit}/${n}") links;
    in
      concatMapStringsSep "\n" (file: "cp -v ${file} $out/") files));

  udevRules = pkgs.runCommand "udev-rules" {
    allowedReferences = [ extraUtils ];
    preferLocalBuild = true;
  } ''
    mkdir -p $out
    cp -v ${udev}/lib/udev/rules.d/60-cdrom_id.rules $out/
    cp -v ${udev}/lib/udev/rules.d/60-persistent-storage.rules $out/
    cp -v ${udev}/lib/udev/rules.d/75-net-description.rules $out/
    cp -v ${udev}/lib/udev/rules.d/80-drivers.rules $out/
    cp -v ${udev}/lib/udev/rules.d/80-net-setup-link.rules $out/
    cp -v ${pkgs.lvm2}/lib/udev/rules.d/*.rules $out/

    ${config.boot.initrd.extraUdevRulesCommands}

    for i in $out/*.rules; do
      substituteInPlace $i \
        --replace ata_id ${extraUtils}/bin/ata_id \
        --replace scsi_id ${extraUtils}/bin/scsi_id \
        --replace cdrom_id ${extraUtils}/bin/cdrom_id \
        --replace ${pkgs.coreutils}/bin/basename ${extraUtils}/bin/basename \
        --replace ${pkgs.util-linux}/bin/blkid ${extraUtils}/bin/blkid \
        --replace ${getBin pkgs.lvm2}/bin ${extraUtils}/bin \
        --replace ${pkgs.mdadm}/sbin ${extraUtils}/sbin \
        --replace ${pkgs.bash}/bin/sh ${extraUtils}/bin/sh \
        --replace ${udev} ${extraUtils}
    done

    substituteInPlace $out/60-persistent-storage.rules \
      --replace ID_CDROM_MEDIA_TRACK_COUNT_DATA ID_CDROM_MEDIA
  ''; # */

  bootStage1 = pkgs.substituteAll {
    src = ./stage-1-init.sh;
    shell = "${extraUtils}/bin/ash";
    isExecutable = true;

    postInstall = ''
      echo checking syntax
      ${pkgs.buildPackages.bash}/bin/sh -n $target
      ${pkgs.buildPackages.busybox}/bin/ash -n $target
    '';

    inherit linkUnits udevRules extraUtils modulesClosure;
    inherit (config.boot) resumeDevice;
    inherit (config.system.expidus) distroName;
    inherit (config.system.build) earlyMountScript;

    inherit (config.boot.initrd) checkJournalingFS verbose
      preLVMCommands preDeviceCommands postDeviceCommands
      postMountCommands preFailCommands kernelModules;

    resumeDevices = map (sd: if sd ? device then sd.device else "/dev/disk/by-label/${sd.label}")
      (filter (sd: hasPrefix "/dev/" sd.device && !sd.randomEncryption.enable
        # Don't include zram devices
        && !(hasPrefix "/dev/zram" sd.device)
      ) config.swapDevices);

    fsInfo =
      let f = fs: [ fs.mountPoint (if fs.device != null then fs.device else "/dev/disk/by-label/${fs.label}") fs.fsType (builtins.concatStringsSep "," fs.options) ];
      in pkgs.writeText "initrd-fsinfo" (concatStringsSep "\n" (concatMap f fileSystems));

    setHostId = optionalString (config.networking.hostId != null) ''
      hi="${config.networking.hostId}"
      ${if pkgs.stdenv.isBigEndian then ''
        echo -ne "\x''${hi:0:2}\x''${hi:2:2}\x''${hi:4:2}\x''${hi:6:2}" > /etc/hostid
      '' else ''
        echo -ne "\x''${hi:6:2}\x''${hi:4:2}\x''${hi:2:2}\x''${hi:0:2}" > /etc/hostid
      ''}
    '';
  };

  initialRamdisk = pkgs.makeInitrd {
    name = "initrd-${kernel-name}";
    inherit (config.boot.initrd) compressor compressorArgs prepend;

    contents = [
      { object = bootStage1; symlink = "/init"; }
      {
        object = pkgs.writeText "mdadm.conf" config.boot.initrd.services.swraid.mdadmConf;
        symlink = "/etc/mdadm.conf";
      }
      {
        object = pkgs.runCommand "initrd-kmod-blacklist-ubuntu" {
          src = "${pkgs.kmod-blacklist-ubuntu}/modprobe.conf";
          preferLocalBuild = true;
        } ''
          target=$out
          ${pkgs.buildPackages.perl}/bin/perl -0pe 's/## file: iwlwifi.conf(.+?)##/##/s;' $src > $out
        '';
        symlink = "/etc/modprobe.d/ubuntu.conf";
      }
      {
        object = config.environment.etc."modprobe.d/expidus.conf".source;
        symlink = "/etc/modprobe.d/expidus.conf";
      }
      {
        object = pkgs.kmod-debian-aliases;
        symlink = "/etc/modprobe.d/debian.conf";
      }
    ] ++ (lib.optionals config.services.multipath.enable [
      {
        object = pkgs.runCommand "multipath.conf" {
          src = config.environment.etc."multipath.conf".text;
          preferLocalBuild = true;
        } ''
          target=$out
          printf "$src" > $out
          substituteInPlace $out \
            --replace ${config.services.multipath.package}/lib ${extraUtils}/lib
        '';
        symlink = "/etc/multipath.conf";
      }
    ]) ++ (lib.mapAttrsToList
      (symlink: options: {
        inherit symlink;
        object = options.source;
      })
      config.boot.initrd.extraFiles);
  };
in
{
  options.fileSystems = mkOption {
    type = with lib.types; attrsOf (submodule {
      options.neededForBoot = mkOption {
        default = false;
        type = types.bool;
        description = mdDoc ''
          If set, this file system will be mounted in the initial ramdisk.
          Note that the file system will always be mounted in the initial
          ramdisk if its mount point is one of the following:
          ${concatStringsSep ", " (
            forEach utils.pathsNeededForBoot (i: "{file}`${i}`")
          )}.
        '';
      };
    });
  };

  options.boot = {
    resumeDevice = mkOption {
      type = types.str;
      default = "";
      example = "/dev/sda3";
      description = mdDoc ''
        Device for manual resume attempt during boot. This should be used primarily
        if you want to resume from file. If left empty, the swap partitions are used.
        Specify here the device where the file resides.
        You should also use {var}`boot.kernelParams` to specify
        `«resume_offset»`.
      '';
    };

    initrd = {
      enable = mkOption {
        type = types.bool;
        default = !config.boot.isContainer;
        defaultText = literalExpression "!config.boot.isContainer";
        description = mdDoc ''
          Whether to enable the initial ramdisk.
        '';
      };

      extraFiles = mkOption {
        default = { };
        type = with types; attrsOf
          (submodule {
            options = {
              source = mkOption {
                type = package;
                description = mdDoc "The object to make available inside the initrd.";
              };
            };
          });
        description = mdDoc ''
          Extra files to link and copy in to the initrd.
        '';
      };

      prepend = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = mdDoc ''
          Other initrd files to prepend to the final initrd we are building.
        '';
      };

      checkJournalingFS = mkOption {
        default = true;
        type = types.bool;
        description = mdDoc ''
          Whether to run {command}`fsck` on journaling filesystems such as ext3.
        '';
      };

      preLVMCommands = mkOption {
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed immediately before LVM discovery.
        '';
      };

      preDeviceCommands = mkOption {
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed before udev is started to create
          device nodes.
        '';
      };

      postDeviceCommands = mkOption {
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed immediately after stage 1 of the
          boot has loaded kernel modules and created device nodes in
          {file}`/dev`.
        '';
      };

      postMountCommands = mkOption {
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed immediately after the stage 1
          filesystems have been mounted.
        '';
      };

      preFailCommands = mkOption {
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed before the failure prompt is shown.
        '';
      };

      extraUtilsCommands = mkOption {
        internal = true;
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed in the builder of the
          extra-utils derivation.  This can be used to provide
          additional utilities in the initial ramdisk.
        '';
      };

      extraUtilsCommandsTest = mkOption {
        internal = true;
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed in the builder of the
          extra-utils derivation after patchelf has done its
          job.  This can be used to test additional utilities
          copied in extraUtilsCommands.
        '';
      };

      extraUdevRulesCommands = mkOption {
        internal = true;
        default = "";
        type = types.lines;
        description = mdDoc ''
          Shell commands to be executed in the builder of the
          udev-rules derivation. This can be used to add
          additional udev rules in the initial ramdisk.
        '';
      };

      compressor = mkOption {
        default = (
          if lib.versionAtLeast config.boot.kernelPackages.kernel.version "5.9"
          then "zstd"
          else "gzip"
        );
        defaultText = literalMD "`zstd` if the kernel supports it (5.9+), `gzip` if not";
        type = with types; either str (functionTo str);
        description = mdDoc ''
          The compressor to use on the initrd image. May be any of:
          - The name of one of the predefined compressors, see {file}`pkgs/build-support/kernel/initrd-compressor-meta.nix` for the definitions.
          - A function which, given the nixpkgs package set, returns the path to a compressor tool, e.g. `pkgs: "''${pkgs.pigz}/bin/pigz"`
          - (not recommended, because it does not work when cross-compiling) the full path to a compressor tool, e.g. `"''${pkgs.pigz}/bin/pigz"`
          The given program should read data from stdin and write it to stdout compressed.
        '';
        example = "xz";
      };

      compressorArgs = mkOption {
        default = null;
        type = with types; nullOr (listOf str);
        description = mdDoc "Arguments to pass to the compressor for the initrd image, or null to use the compressor's defaults.";
      };

      supportedFilesystems = mkOption {
        default = [ ];
        example = [ "btrfs" ];
        type = types.listOf types.str;
        description = lib.mdDoc "Names of supported filesystem types in the initial ramdisk.";
      };

      verbose = mkOption {
        default = true;
        type = types.bool;
        description = mdDoc ''
          Verbosity of the initrd. Please note that disabling verbosity removes
          only the mandatory messages generated by the NixOS scripts. For a
          completely silent boot, you might also want to set the two following
          configuration options:
          - `boot.consoleLogLevel = 0;`
          - `boot.kernelParams = [ "quiet" "udev.log_level=3" ];`
        '';
      };
    };
  };

  config = mkIf config.boot.initrd.enable {
    assertions = [
      {
        assertion = any (fs: fs.mountPoint == "/") fileSystems;
        message = "The ‘fileSystems’ option does not specify your root file system.";
      }
      {
        assertion = let inherit (config.boot) resumeDevice; in
          resumeDevice == "" || builtins.substring 0 1 resumeDevice == "/";
        message = "boot.resumeDevice has to be an absolute path."
          + " Old \"x:y\" style is no longer supported.";
      }
    ];

    system = {
      build = mkMerge [
        { inherit bootStage1 extraUtils; }
        (mkIf (!config.boot.initrd.systemd.enable) { inherit initialRamdisk; })
      ];

      requiredKernelConfig = with config.lib.kernelConfig; [
        (isYes "TMPFS")
        (isYes "BLK_DEV_INITRD")
      ];
    };

    boot.initrd.supportedFilesystems = map (fs: fs.fsType) fileSystems;
  };
}