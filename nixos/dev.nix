{ config, lib, pkgs, ... }:
with lib;
let
  nixpkgs = import ../lib/channels/nixpkgs.nix;
  loginMessage = "ExpidusOS Development Virtual Machine (EDVM)";

  platformString = platform:
    let
      endian = if platform.isLittleEndian then "little" else "big";
    in platform.system + "-" + endian;
in
{
  imports = [
    ./modules/virtualisation/qemu-vm.nix
    (nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
  ];

  virtualisation = {
    memorySize = 2048;
    cores = 2;
    qemu.options = [
      "--enable-kvm"
      "-m 8G"
      "-device intel-hda"
      "-usb"
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };

  networking.hostName = "expidus-devvm";
  programs.xwayland.enable = true;
  hardware.opengl.enable = true;

  system.defaultChannel = "${pkgs.expidus-sdk}/lib/expidus-sdk/latest/${platformString pkgs.hostPlatform}/${platformString pkgs.targetPlatform}/nix/channel";

  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs; [ expidus-sdk xorg.xinit git gdb ];

  system.activationScripts.nix = stringAfter [ "etc" "users" ] ''
    install -m 0755 -d /nix/var/nix/{gcroots,profiles}/per-user

    # Subscribe the root user to the NixOS channel by default.
    if [ ! -e "/root/.nix-channels" ]; then
      echo "file://${config.system.defaultChannel} nixos" > "/root/.nix-channels"
    fi

    # Add the channel to
    if [ ! -e "/home/expidus-devel/.nix-channels" ]; then
      echo "file://${config.system.defaultChannel} nixos" > "/root/.nix-channels"
    fi
  '';

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.getty = {
    greetingLine = loginMessage;
    autologinUser = "developer";
  };

  services.openssh = {
    enable = true;
    banner = loginMessage;
    permitRootLogin = "without-password";
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager.genesis = {
      enable = true;
      sessions = {
        i3.enable = true;
        sway.enable = true;
      };
    };
  };

  users.users.developer = {
    createHome = true;
    home = "/home/expidus-devel";
    description = "Development test user";
    group = "wheel";
    password = "developer";
    isNormalUser = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
