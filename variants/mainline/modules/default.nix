{ nixpkgs, ... }:
let
  nixpkgsUtils = { lib, config, pkgs, ... }: import "${nixpkgs}/nixos/lib/utils.nix" { inherit lib config pkgs; };
  nixpkgsImport = module: { config, lib, pkgs, ... }@args:
    let
      utils = nixpkgsUtils args;
      _module = import module (args // {
        inherit utils;
      });
    in _module // {
      _file = module;
      key = module;
    };
in
[
  ./security/wrappers.nix
  ./services/ttys/getty.nix
  ./services/x11/xserver.nix
  (nixpkgsImport ./system/boot/initrd.nix)
  ./system/boot/modprobe.nix
  ./system/boot/stage-2.nix
  ./system/build/activation.nix
  ./system/build/datafs.nix
  ./system/build/etc.nix
  ./system/build/rootfs.nix
  ./system/build/system-path.nix
  ./system/build/toplevel.nix
  ./system/tools/default.nix
  ./system/vendor-config.nix
  ./system/version.nix
  (nixpkgsImport ./tasks/network-interfaces.nix)
  ./virtualisation/nixos-containers.nix
  "${nixpkgs}/nixos/modules/config/fonts/fontconfig.nix"
  "${nixpkgs}/nixos/modules/config/fonts/fonts.nix"
  "${nixpkgs}/nixos/modules/config/krb5/default.nix"
  "${nixpkgs}/nixos/modules/config/iproute2.nix"
  "${nixpkgs}/nixos/modules/config/ldap.nix"
  "${nixpkgs}/nixos/modules/config/malloc.nix"
  "${nixpkgs}/nixos/modules/config/mysql.nix"
  "${nixpkgs}/nixos/modules/config/networking.nix"
  "${nixpkgs}/nixos/modules/config/nsswitch.nix"
  "${nixpkgs}/nixos/modules/config/power-management.nix"
  "${nixpkgs}/nixos/modules/config/pulseaudio.nix"
  "${nixpkgs}/nixos/modules/config/resolvconf.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/config/shells-environment.nix")
  "${nixpkgs}/nixos/modules/config/swap.nix"
  "${nixpkgs}/nixos/modules/config/sysctl.nix"
  "${nixpkgs}/nixos/modules/config/system-environment.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/config/users-groups.nix")
  "${nixpkgs}/nixos/modules/config/vte.nix"
  "${nixpkgs}/nixos/modules/hardware/all-firmware.nix"
  "${nixpkgs}/nixos/modules/hardware/device-tree.nix"
  "${nixpkgs}/nixos/modules/hardware/opengl.nix"
  "${nixpkgs}/nixos/modules/hardware/uinput.nix"
  "${nixpkgs}/nixos/modules/misc/assertions.nix"
  "${nixpkgs}/nixos/modules/misc/ids.nix"
  "${nixpkgs}/nixos/modules/misc/lib.nix"
  "${nixpkgs}/nixos/modules/misc/meta.nix"
  "${nixpkgs}/nixos/modules/misc/nixpkgs.nix"
  "${nixpkgs}/nixos/modules/programs/bash/bash-completion.nix"
  "${nixpkgs}/nixos/modules/programs/bash/bash.nix"
  "${nixpkgs}/nixos/modules/programs/zsh/zsh.nix"
  "${nixpkgs}/nixos/modules/programs/environment.nix"
  "${nixpkgs}/nixos/modules/programs/less.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/programs/shadow.nix")
  "${nixpkgs}/nixos/modules/programs/ssh.nix"
  "${nixpkgs}/nixos/modules/security/apparmor.nix"
  "${nixpkgs}/nixos/modules/security/oath.nix"
  "${nixpkgs}/nixos/modules/security/pam_mount.nix"
  "${nixpkgs}/nixos/modules/security/pam_usb.nix"
  "${nixpkgs}/nixos/modules/security/pam.nix"
  "${nixpkgs}/nixos/modules/security/polkit.nix"
  "${nixpkgs}/nixos/modules/security/rtkit.nix"
  "${nixpkgs}/nixos/modules/services/audio/alsa.nix"
  "${nixpkgs}/nixos/modules/services/hardware/actkbd.nix"
  "${nixpkgs}/nixos/modules/services/hardware/bluetooth.nix"
  "${nixpkgs}/nixos/modules/services/hardware/udev.nix"
  "${nixpkgs}/nixos/modules/services/logging/logrotate.nix"
  "${nixpkgs}/nixos/modules/services/logging/rsyslogd.nix"
  "${nixpkgs}/nixos/modules/services/logging/syslog-ng.nix"
  "${nixpkgs}/nixos/modules/services/misc/sssd.nix"
  "${nixpkgs}/nixos/modules/services/networking/ssh/sshd.nix"
  "${nixpkgs}/nixos/modules/services/networking/avahi-daemon.nix"
  "${nixpkgs}/nixos/modules/services/networking/dhcpcd.nix"
  "${nixpkgs}/nixos/modules/services/networking/firewall.nix"
  "${nixpkgs}/nixos/modules/services/networking/iwd.nix"
  "${nixpkgs}/nixos/modules/services/networking/mstpd.nix"
  "${nixpkgs}/nixos/modules/services/networking/multipath.nix"
  "${nixpkgs}/nixos/modules/services/networking/networkmanager.nix"
  "${nixpkgs}/nixos/modules/services/networking/wpa_supplicant.nix"
  "${nixpkgs}/nixos/modules/services/security/fprintd.nix"
  "${nixpkgs}/nixos/modules/services/system/dbus.nix"
  "${nixpkgs}/nixos/modules/services/system/nscd.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/coredump.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/initrd.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/journald.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/logind.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/nspawn.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/oomd.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/shutdown.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/tmpfiles.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/user.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/networkd.nix")
  "${nixpkgs}/nixos/modules/system/boot/kernel.nix"
  "${nixpkgs}/nixos/modules/system/boot/kernel_config.nix"
  "${nixpkgs}/nixos/modules/system/boot/resolved.nix"
  "${nixpkgs}/nixos/modules/system/etc/etc.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/tasks/filesystems.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/tasks/network-interfaces-scripted.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/tasks/network-interfaces-systemd.nix")
  "${nixpkgs}/nixos/modules/tasks/swraid.nix"
  "${nixpkgs}/nixos/modules/virtualisation/lxc.nix"
  "${nixpkgs}/nixos/modules/virtualisation/lxcfs.nix"
  "${nixpkgs}/nixos/modules/virtualisation/openvswitch.nix"
]
