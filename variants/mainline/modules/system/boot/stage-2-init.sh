#!@shell@

systemConfig=@systemConfig@

export HOME=/root PATH="@path@"

if [ "${IN_NIXOS_SYSTEMD_STAGE1:-}" != true ]; then
  # Process the kernel command line.
  for o in $(</proc/cmdline); do
    case $o in
      boot.debugtrace)
        # Show each command.
        set -x
        ;;
    esac
  done

  echo
  echo -e "\e[1;32m<<< @distroName@ Stage 2 >>>\e[0m"
  echo
fi

if [ ! -e /proc/1 ]; then
  specialMount() {
    local device="$1"
    local mountPoint="$2"
    local options="$3"
    local fsType="$4"

    if [ "${IN_NIXOS_SYSTEMD_STAGE1:-}" = true ] && [ "${mountPoint}" = /run ]; then
      return
    fi

    install -m 0755 -d "$mountPoint"
    mount -n -t "$fsType" -o "$options" "$device" "$mountPoint"
  }
  source @earlyMountScript@
fi

if [ "${IN_NIXOS_SYSTEMD_STAGE1:-}" = true ]; then
  echo "booting system configuration ${systemConfig}"
else
  echo "booting system configuration $systemConfig" > /dev/kmsg
fi

mount --bind /data/var/cache /var/cache
mount --bind /data/var/lib /var/lib
mount --bind /data/var/log /var/log
mount --bind /data/users /home

# TODO: manage Nix store

if [ "${IN_NIXOS_SYSTEMD_STAGE1:-}" != true ]; then
  if [ -n "@useHostResolvConf@" ] && [ -e /etc/resolv.conf ]; then
    resolvconf -m 1000 -a host </etc/resolv.conf
  fi

  exec {logOutFd}>&1 {logErrFd}>&2

  if test -w /dev/kmsg; then
    exec > >(tee -i /proc/self/fd/"$logOutFd" | while read -r line; do
      if test -n "$line"; then
        echo "<7>stage-2-init: $line" > /dev/kmsg
      fi
    done) 2>&1
  else
    mkdir -p /run/log
    exec > >(tee -i /run/log/stage-2-init.log) 2>&1
  fi
fi

@shell@ @postBootCommands@

if [ "${IN_NIXOS_SYSTEMD_STAGE1:-}" != true ]; then
  # Reset the logging file descriptors.
  exec 1>&$logOutFd 2>&$logErrFd
  exec {logOutFd}>&- {logErrFd}>&-

  # Start systemd in a clean environment.
  echo "starting systemd..."
  exec @systemdExecutable@ "$@"
fi
