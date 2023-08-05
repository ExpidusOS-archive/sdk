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
  ({ lib, ... }: {
    disabledModules = [
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/xterm.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/phosh.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/xfce.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/plasma5.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/lumina.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/lxqt.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/enlightenment.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/gnome.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/retroarch.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/kodi.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/mate.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/pantheon.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/surf-display.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/cde.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/cinnamon.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/budgie.nix"
      "${nixpkgs}/nixos/modules/services/x11/desktop-managers/deepin.nix"
    ];

    config = {
      boot.tmp.useTmpfs = lib.mkForce true;

      system.activationScripts.fonts = ''
        mkdir -p /usr/share
        ln -sf /run/current-system/sw/share/X11/fonts/ /usr/share/fonts
      '';
    };
  })
  ./security/wrappers.nix
  ./services/desktops/genesis/default.nix
  ./services/ttys/getty.nix
  (nixpkgsImport ./services/x11/xserver.nix)
  (nixpkgsImport ./system/boot/systemd/tmpfiles.nix)
  (nixpkgsImport ./system/boot/initrd.nix)
  ./system/boot/modprobe.nix
  ./system/boot/stage-2.nix
  (nixpkgsImport ./system/boot/systemd.nix)
  ./system/build/activation.nix
  ./system/build/datafs.nix
  ./system/build/efipart.nix
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
  "${nixpkgs}/nixos/modules/config/fonts/fontdir.nix"
  "${nixpkgs}/nixos/modules/config/fonts/ghostscript.nix"
  "${nixpkgs}/nixos/modules/config/fonts/packages.nix"
  "${nixpkgs}/nixos/modules/config/krb5/default.nix"
  "${nixpkgs}/nixos/modules/config/xdg/portals/wlr.nix"
  "${nixpkgs}/nixos/modules/config/xdg/autostart.nix"
  "${nixpkgs}/nixos/modules/config/xdg/icons.nix"
  "${nixpkgs}/nixos/modules/config/xdg/menus.nix"
  "${nixpkgs}/nixos/modules/config/xdg/mime.nix"
  "${nixpkgs}/nixos/modules/config/xdg/portal.nix"
  "${nixpkgs}/nixos/modules/config/console.nix"
  "${nixpkgs}/nixos/modules/config/i18n.nix"
  "${nixpkgs}/nixos/modules/config/iproute2.nix"
  "${nixpkgs}/nixos/modules/config/ldap.nix"
  "${nixpkgs}/nixos/modules/config/locale.nix"
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
  "${nixpkgs}/nixos/modules/config/terminfo.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/config/users-groups.nix")
  "${nixpkgs}/nixos/modules/config/vte.nix"
  "${nixpkgs}/nixos/modules/hardware/all-firmware.nix"
  "${nixpkgs}/nixos/modules/hardware/device-tree.nix"
  "${nixpkgs}/nixos/modules/hardware/opengl.nix"
  "${nixpkgs}/nixos/modules/hardware/uinput.nix"
  "${nixpkgs}/nixos/modules/services/hardware/upower.nix"
  "${nixpkgs}/nixos/modules/misc/assertions.nix"
  "${nixpkgs}/nixos/modules/misc/ids.nix"
  "${nixpkgs}/nixos/modules/misc/lib.nix"
  "${nixpkgs}/nixos/modules/misc/meta.nix"
  "${nixpkgs}/nixos/modules/misc/nixpkgs.nix"
  "${nixpkgs}/nixos/modules/programs/bash/bash-completion.nix"
  "${nixpkgs}/nixos/modules/programs/bash/bash.nix"
  "${nixpkgs}/nixos/modules/programs/zsh/zsh.nix"
  "${nixpkgs}/nixos/modules/programs/environment.nix"
  "${nixpkgs}/nixos/modules/programs/feedbackd.nix"
  "${nixpkgs}/nixos/modules/programs/less.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/programs/shadow.nix")
  "${nixpkgs}/nixos/modules/programs/ssh.nix"
  "${nixpkgs}/nixos/modules/programs/xwayland.nix"
  "${nixpkgs}/nixos/modules/security/apparmor.nix"
  "${nixpkgs}/nixos/modules/security/oath.nix"
  "${nixpkgs}/nixos/modules/security/pam_mount.nix"
  "${nixpkgs}/nixos/modules/security/pam_usb.nix"
  "${nixpkgs}/nixos/modules/security/pam.nix"
  "${nixpkgs}/nixos/modules/security/polkit.nix"
  "${nixpkgs}/nixos/modules/security/rtkit.nix"
  "${nixpkgs}/nixos/modules/security/sudo.nix"
  "${nixpkgs}/nixos/modules/services/audio/alsa.nix"
  "${nixpkgs}/nixos/modules/services/desktops/accountsservice.nix"
  "${nixpkgs}/nixos/modules/services/desktops/geoclue2.nix"
  "${nixpkgs}/nixos/modules/services/hardware/acpid.nix"
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
  "${nixpkgs}/nixos/modules/services/networking/nftables.nix"
  "${nixpkgs}/nixos/modules/services/networking/iwd.nix"
  "${nixpkgs}/nixos/modules/services/networking/mstpd.nix"
  "${nixpkgs}/nixos/modules/services/networking/multipath.nix"
  "${nixpkgs}/nixos/modules/services/networking/networkmanager.nix"
  "${nixpkgs}/nixos/modules/services/networking/wpa_supplicant.nix"
  "${nixpkgs}/nixos/modules/services/security/fprintd.nix"
  "${nixpkgs}/nixos/modules/services/security/kanidm.nix"
  "${nixpkgs}/nixos/modules/services/system/dbus.nix"
  "${nixpkgs}/nixos/modules/services/system/nscd.nix"
  "${nixpkgs}/nixos/modules/services/x11/desktop-managers/default.nix"
  "${nixpkgs}/nixos/modules/services/x11/display-managers/default.nix"
  "${nixpkgs}/nixos/modules/services/x11/window-managers/default.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/coredump.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/initrd.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/homed.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/journald.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/logind.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/nspawn.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/oomd.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/shutdown.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/user.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd/userdbd.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/systemd.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/system/boot/networkd.nix")
  "${nixpkgs}/nixos/modules/system/boot/kernel.nix"
  "${nixpkgs}/nixos/modules/system/boot/kernel_config.nix"
  "${nixpkgs}/nixos/modules/system/boot/plymouth.nix"
  "${nixpkgs}/nixos/modules/system/boot/resolved.nix"
  "${nixpkgs}/nixos/modules/system/boot/tmp.nix"
  "${nixpkgs}/nixos/modules/system/etc/etc.nix"
  (nixpkgsImport "${nixpkgs}/nixos/modules/tasks/filesystems.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/tasks/network-interfaces-scripted.nix")
  (nixpkgsImport "${nixpkgs}/nixos/modules/tasks/network-interfaces-systemd.nix")
  "${nixpkgs}/nixos/modules/tasks/swraid.nix"
  "${nixpkgs}/nixos/modules/virtualisation/lxc.nix"
  "${nixpkgs}/nixos/modules/virtualisation/lxcfs.nix"
  "${nixpkgs}/nixos/modules/virtualisation/openvswitch.nix"
]
