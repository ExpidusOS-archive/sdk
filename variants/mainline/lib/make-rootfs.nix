{ pkgs,
  lib ? pkgs.lib,
  options ? [],
  config,
  diskSize ? "auto",
  format ? "raw",
  additionalSpace ? "1G",
  additionalPaths ? [],
  contents ? [],
  postVM ? "",
  mutable ? false,
  name ? "${config.system.build.toplevel.name}-rootfs"
}:
assert (lib.assertMsg (lib.all
  (attrs: ((attrs.user  or null) == null)
    == ((attrs.group or null) == null))
  contents) "Contents of the disk image should set none of {user, group} or both at the same time.");
assert (lib.assertMsg (!mutable -> format == "raw") "format must be raw on immutable images");
with lib;
let format' = format; in let
  format = if format' == "qcow2-compressed" then "qcow2" else format';
  compress = optionalString (format' == "qcow2-compressed") "-c";

  filename = "${name}." + {
    qcow2 = "qcow2";
    vdi = "vdi";
    vpc = "vhd";
    raw = "img";
  }.${format} or format;

  sources = map (x: x.source) contents;
  targets = map (x: x.target) contents;
  modes = map (x: x.mode or "''") contents;
  users = map (x: x.user or "''") contents;
  groups = map (x: x.group or "''") contents;

  binPath = with pkgs; makeBinPath ([
    config.system.build.nixos-install
    config.system.build.nixos-enter
    rsync
    nix
    lkl
    e2fsprogs
    erofs-utils
  ]
    ++ stdenv.initialPath);

  basePaths = [
    config.system.build.toplevel
  ];

  additionalPaths' = subtractLists basePaths additionalPaths;

  closureInfo = pkgs.closureInfo {
    rootPaths = basePaths ++ additionalPaths';
  };

  blockSize = toString (4 * 1024);

  prepareImage = ''
    export PATH=${binPath}

    # Yes, mkfs.ext4 takes different units in different contexts. Fun.
    sectorsToKilobytes() {
      echo $(( ( "$1" * 512 ) / 1024 ))
    }

    sectorsToBytes() {
      echo $(( "$1" * 512 ))
    }

    # Given lines of numbers, adds them together
    sum_lines() {
      local acc=0
      while read -r number; do
        acc=$((acc+number))
      done
      echo "$acc"
    }

    mebibyte=$((1024 * 1024))

    # Approximative percentage of reserved space in an ext4 fs over 512MiB.
    # 0.05208587646484375
    #  × 1000, integer part: 52
    compute_fudge() {
      echo $(($1 * 52 / 1000))
    }

    mkdir $out
    export root="$PWD/root"
    mkdir -p $root

    mkdir -p $root/{bin,boot,dev,lib,mnt,nix/store,opt,proc,root,run,sbin,sys,tmp,usr}
    mkdir -p $root/var/{empty,lock,spool}
    mkdir -p $root/data

    mkdir -m 0755 -p $root/etc
    mkdir -p $root/etc/NetworkManager/dispatcher.d
    touch $root/etc/EXPIDUS

    ln -s /data/config/machine-id $root/etc/machine-id
    ln -s /data/config/resolv.conf $root/etc/resolv.conf
    ln -s /data/config/networks $root/etc/NetworkManager/system-connections
    ln -s /data/var/cache $root/var/cache
    ln -s /data/var/db $root/var/db
    ln -s /data/var/lib $root/var/lib
    ln -s /data/var/log $root/var/log
    ln -s /data/var/tmp $root/var/tmp
    ln -s /data/users $root/home
    ln -s /run $root/var/run

    set -f
    sources_=(${concatStringsSep " " sources})
    targets_=(${concatStringsSep " " targets})
    modes_=(${concatStringsSep " " modes})
    set +f

    for ((i = 0; i < ''${#targets_[@]}; i++)); do
      source="''${sources_[$i]}"
      target="''${targets_[$i]}"
      mode="''${modes_[$i]}"

      if [ -n "$mode" ]; then
        rsync_chmod_flags="--chmod=$mode"
      else
        rsync_chmod_flags=""
      fi

      # Unfortunately cptofs only supports modes, not ownership, so we can't use
      # rsync's --chown option. Instead, we change the ownerships in the
      # VM script with chown.
      rsync_flags="-a --no-o --no-g $rsync_chmod_flags"

      if [[ "$source" =~ '*' ]]; then
        # If the source name contains '*', perform globbing.
        mkdir -p $root/$target
        for fn in $source; do
          rsync $rsync_flags "$fn" $root/$target/
        done
      else
        mkdir -p $root/$(dirname $target)
        if ! [ -e $root/$target ]; then
          rsync $rsync_flags $source $root/$target
        else
          echo "duplicate entry $target -> $source"
          exit 1
        fi
      fi
    done

    export HOME=$TMPDIR
    export NIX_STATE_DIR=$TMPDIR/state
    nix-store --load-db < ${closureInfo}/registration

    chmod 755 "$TMPDIR"

    nixos-install --root $root --no-bootloader --no-root-passwd \
      --system ${config.system.build.toplevel} \
      --no-channel-copy \
      --substituters ""

    ${optionalString (additionalPaths' != []) ''
      nix --extra-experimental-features nix-command copy --to $root --no-check-sigs ${concatStringsSep " " additionalPaths'}
    ''}

    cp --no-preserve=ownership,mode -r $root "$out/root"

    for path in $(find $root -type f -executable); do
      rpath=$(echo $path | sed "s|$root|$out/root|g")
      rm -rf "$rpath"
      cp -r $path $rpath
    done

    export root="$out/root"

    ${if diskSize == "auto" then ''
      additionalSpace=$(($(numfmt --from=iec '${additionalSpace}')))

      diskUsage=$(find . ! -type d -print0 | du --files0-from=- --apparent-size --block-size "${blockSize}" | cut -f1 | sum_lines)
      # Each inode takes space!
      numInodes=$(find . | wc -l)
      # Convert to bytes, inodes take two blocks each!
      diskUsage=$(( (diskUsage + 2 * numInodes) * ${blockSize} ))
      # Then increase the required space to account for the reserved blocks.
      fudge=$(compute_fudge $diskUsage)
      requiredFilesystemSpace=$(( diskUsage + fudge ))
      diskSize=$(( requiredFilesystemSpace  + additionalSpace ))

      # Round up to the nearest mebibyte.
      # This ensures whole 512 bytes sector sizes in the disk image
      # and helps towards aligning partitions optimally.
      if (( diskSize % mebibyte )); then
        diskSize=$(( ( diskSize / mebibyte + 1) * mebibyte ))
      fi

      truncate -s $diskSize $out/img

      printf "Automatic disk size...\n"
      printf "  Closure space use: %d bytes\n" $diskUsage
      printf "  fudge: %d bytes\n" $fudge
      printf "  Filesystem size needed: %d bytes\n" $requiredFilesystemSpace
      printf "  Additional space: %d bytes\n" $additionalSpace
      printf "  Disk image size: %d bytes\n" $diskSize
    '' else ''
      truncate -s ${toString diskSize} $out/img
    ''}

    ${if mutable then ''
      mkfs.ext4 -b ${blockSize} ${lib.concatMapStrings (x: x + " ") options} -F $out/img
      cptofs -t ext4 -i $out $root/* / ||
        (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)
    '' else ''
      mkfs.erofs ${lib.concatMapStrings (x: x + " ") options} $out/img $root
    ''}
  '';

  moveImage = ''
    ${if format == "raw" then ''
      mv $out/img $NIX_BUILD_TOP/${filename}
    '' else ''
      ${pkgs.qemu}/bin/qemu-img convert -f raw -O ${format} ${compress} $out/img $NIX_BUILD_TOP/${filename}
    ''}

    rm -rf $out
    mv $NIX_BUILD_TOP/${filename} $out
  '';
in pkgs.vmTools.runInLinuxVM (pkgs.runCommand filename {
  preVM = prepareImage;
  buildInputs = with pkgs; [ erofs-utils util-linux e2fsprogs dosfstools ];
  postVM = moveImage + postVM;
  memSize = 1024 * 8;
} ''
  export PATH=${binPath}:$PATH

  # Yes, mkfs.ext4 takes different units in different contexts. Fun.
  sectorsToKilobytes() {
    echo $(( ( "$1" * 512 ) / 1024 ))
  }

  sectorsToBytes() {
    echo $(( "$1" * 512 ))
  }

  # Given lines of numbers, adds them together
  sum_lines() {
    local acc=0
    while read -r number; do
      acc=$((acc+number))
    done
    echo "$acc"
  }

  mebibyte=$((1024 * 1024))

  # Approximative percentage of reserved space in an ext4 fs over 512MiB.
  # 0.05208587646484375
  #  × 1000, integer part: 52
  compute_fudge() {
    echo $(($1 * 52 / 1000))
  }

  mkdir /dev/block
  ln -s /dev/vda /dev/block/254:1

  rootDisk=$out/img
  mountPoint=/mnt
  mkdir $mountPoint

  ${if mutable then ''
    mount $rootDisk $mountPoint
  '' else ''
    mkdir /mnt-{upper,work}
    mkdir /build
    ln -s $out/root /build/root
    mount -t overlay overlay -o lowerdir=$out/root,upperdir=/mnt-upper,workdir=/mnt-work $mountPoint
  ''}

  mkdir -p /tmp/datafs
  mkdir -p /tmp/datafs/users
  mkdir -p /tmp/datafs/var/lib
  mkdir -p /tmp/datafs/var/tmp

  chown -R root $mountPoint
  mount --bind /tmp/datafs $mountPoint/data

  targets_=(${concatStringsSep " " targets})
  users_=(${concatStringsSep " " users})
  groups_=(${concatStringsSep " " groups})
  for ((i = 0; i < ''${#targets_[@]}; i++)); do
    target="''${targets_[$i]}"
    user="''${users_[$i]}"
    group="''${groups_[$i]}"

    if [ -n "$user$group" ]; then
      # We have to nixos-enter since we need to use the user and group of the VM
      nixos-enter --root $mountPoint -- chown -R "$user:$group" "$target"
    fi
  done

  nixos-enter --root $mountPoint -- "${config.system.build.toplevel.outPath}/activate"
  rm $mountPoint/etc/NIXOS

  rm $mountPoint${config.system.build.toplevel.outPath}/activate
  rm -rf $mountPoint${config.system.build.toplevel.outPath}/etc
  rm -rf $mountPoint${config.system.build.etc.outPath}
  rm -rf $mountPoint/etc/static
  cp -r ${config.system.build.etc.outPath}/etc $mountPoint/etc/static
  # TODO: remove any already existing file from /etc/static
  # FIXME: out-of-space issues with immutable rootfs
  rm -rf $mountPoint/nix/store/.links
  rm -rf $mountPoint/nix/var

  umount $mountPoint/data

  ${optionalString (diskSize == "auto") ''
    additionalSpace=$(($(numfmt --from=iec '${additionalSpace}')))

    diskUsage=$(find $mountPoint ! -type d -print0 | du --files0-from=- --apparent-size --block-size "${blockSize}" | cut -f1 | sum_lines)
    # Each inode takes space!
    numInodes=$(find $mountPoint | wc -l)
    # Convert to bytes, inodes take two blocks each!
    diskUsage=$(( (diskUsage + 2 * numInodes) * ${blockSize} ))
    # Then increase the required space to account for the reserved blocks.
    fudge=$(compute_fudge $diskUsage)
    requiredFilesystemSpace=$(( diskUsage + fudge ))
    diskSize=$(( requiredFilesystemSpace  + additionalSpace ))

    # Round up to the nearest mebibyte.
    # This ensures whole 512 bytes sector sizes in the disk image
    # and helps towards aligning partitions optimally.
    if (( diskSize % mebibyte )); then
      diskSize=$(( ( diskSize / mebibyte + 1) * mebibyte ))
    fi

    truncate -s $diskSize $rootDisk

    printf "Automatic disk size...\n"
    printf "  Closure space use: %d bytes\n" $diskUsage
    printf "  fudge: %d bytes\n" $fudge
    printf "  Filesystem size needed: %d bytes\n" $requiredFilesystemSpace
    printf "  Additional space: %d bytes\n" $additionalSpace
    printf "  Disk image size: %d bytes\n" $diskSize
  ''}

  ${if mutable then ''
    umount -R $mountPoint
  '' else ''
    mkfs.erofs ${lib.concatMapStrings (x: x + " ") options} $rootDisk $mountPoint
    umount -R $mountPoint
  ''}
'')
