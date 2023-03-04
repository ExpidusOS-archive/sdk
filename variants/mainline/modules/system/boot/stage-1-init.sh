#!@shell@

targetRoot=/mnt-root
console=tty1
verbose="@verbose@"

info() {
  if [[ -n "$verbose" ]]; then
    echo "$@"
  fi
}

extraUtils="@extraUtils@"
export LD_LIBRARY_PATH=@extraUtils@/lib
export PATH=@extraUtils@/bin
ln -s @extraUtils@/bin /bin
# hardcoded in util-linux's mount helper search path `/run/wrappers/bin:/run/current-system/sw/bin:/sbin`
ln -s @extraUtils@/bin /sbin

# Stop LVM complaining about fd3
export LVM_SUPPRESS_FD_WARNINGS=true

fail() {
  if [ -n "$panicOnFail" ]; then exit 1; fi

  @preFailCommands@

  # If starting stage 2 failed, allow the user to repair the problem
  # in an interactive shell.
  cat <<EOF
An error occurred in stage 1 of the boot process, which must mount the
root filesystem on \`$targetRoot' and then start stage 2.  Press one
of the following keys:
EOF
  if [ -n "$allowShell" ]; then cat <<EOF
  i) to launch an interactive shell
  f) to start an interactive shell having pid 1 (needed if you want to
     start stage 2's init manually)
EOF
  fi
  cat <<EOF
  r) to reboot immediately
  *) to ignore the error and continue
EOF

  read -n 1 reply

  if [ -n "$allowShell" -a "$reply" = f ]; then
    exec setsid @shell@ -c "exec @shell@ < /dev/$console >/dev/$console 2>/dev/$console"
  elif [ -n "$allowShell" -a "$reply" = i ]; then
    echo "Starting interactive shell..."
    setsid @shell@ -c "exec @shell@ < /dev/$console >/dev/$console 2>/dev/$console" || fail
  elif [ "$reply" = r ]; then
    echo "Rebooting..."
    reboot -f
  else
    info "Continuing..."
  fi
}

trap 'fail' 0

info
info "[1;32m<<< @distroName@ Stage 1 >>>[0m"
info
