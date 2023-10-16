{ pkgs,
  lib ? pkgs.lib,
  config,
  diskSize ? "512M",
  format ? "raw",
  contents ? [],
  postVM ? "",
  name ? "${config.system.build.toplevel.name}-efipart"
}:
assert (lib.assertMsg (lib.all
  (attrs: ((attrs.user  or null) == null)
    == ((attrs.group or null) == null))
  contents) "Contents of the disk image should set none of {user, group} or both at the same time.");
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
    rsync
    lkl
    dosfstools
  ]
    ++ stdenv.initialPath);

  blockSize = toString (4 * 1024);

  arch = pkgs.targetPlatform.efiArch;
  prepareImage = ''
    export PATH=${binPath}

    mkdir $out
    root="$PWD/root"
    mkdir -p $root/EFI/{BOOT,refind,expidus}
    cp ${pkgs.refind}/share/refind/refind_${arch}.efi $root/EFI/BOOT/BOOT${arch}.efi
    cp ${config.system.build.refindConfig} $root/EFI/BOOT/refind.conf

    cp -r ${pkgs.refind}/share/refind/drivers_${arch} $root/EFI/refind/drivers_${arch}
    cp -r ${pkgs.refind}/share/refind/icons $root/EFI/refind/icons
    cp -r ${pkgs.refind}/share/refind/fonts $root/EFI/refind/fonts

    ${optionalString (config.boot.efi.populateRootfs == false) ''
      cp ${config.system.build.kernel}/${pkgs.stdenv.hostPlatform.linux-kernel.target} $root/EFI/expidus/vmlinuz
      cp ${config.system.build.initialRamdisk}/initrd $root/EFI/expidus/initramfs.img
    ''}

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

    diskImage=expidus-efipart.raw

    truncate -s ${toString diskSize} $diskImage
    mkfs.fat -F32 $diskImage
    cptofs -t vfat -i $diskImage $root/* / ||
      (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)
  '';

  moveImage = ''
    rmdir $out
    ${if format == "raw" then ''
      mv $diskImage $out
    '' else ''
      ${pkgs.qemu}/bin/qemu-img convert -f raw -O ${format} ${compress} $diskImage $out
    ''}
    diskImage=$out
  '';
in pkgs.vmTools.runInLinuxVM (pkgs.runCommand filename {
  preVM = prepareImage;
  buildInputs = with pkgs; [ util-linux e2fsprogs dosfstools squashfsTools ];
  QEMU_OPTS = "-drive if=virtio,format=raw,readonly=on,file=${config.system.build.rootfs}";
  postVM = moveImage + postVM;
  memSize = 1024 * 2;
} ''
  export PATH=${binPath}:$PATH

  mkdir /dev/block
  ln -s /dev/vda /dev/block/253:1
  ln -s /dev/vdb /dev/block/254:1

  rootDisk=/dev/vdb
  dataDisk=/dev/vda
  mountPoint=/mnt
  dataMount=/mnt-data

  mkdir $mountPoint $dataMount
  mount $rootDisk $mountPoint

  mount $dataDisk $dataMount

  mount --bind $dataMount $mountPoint/boot/efi

  targets_=(${concatStringsSep " " targets})
  users_=(${concatStringsSep " " users})
  groups_=(${concatStringsSep " " groups})
  for ((i = 0; i < ''${#targets_[@]}; i++)); do
    target="''${targets_[$i]}"
    user="''${users_[$i]}"
    group="''${groups_[$i]}"

    if [ -n "$user$group" ]; then
      chroot $mountPoint chown -R "$user:$group" "/var/run/expidus/$target"
    fi
  done

  umount $mountPoint/boot/efi
  umount $mountPoint

  umount -R /mnt-data
'')
