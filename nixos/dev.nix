{ config, lib, pkgs, ... }:
with lib;
let
  nixpkgs = import ../lib/nixpkgs.nix;
  loginMessage = "ExpidusOS Development Virtual Machine (EDVM)";

  platformString = platform:
    let
      endian = if platform.isLittleEndian then "little" else "big";
    in platform.system + "-" + endian;

  channelPath = "${pkgs.expidus-sdk}/lib/expidus-sdk/latest/${platformString pkgs.hostPlatform}/${platformString pkgs.targetPlatform}/nix/channel";
in
{
  imports = [
    (nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
    (nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
  ];

  virtualisation = {
    memorySize = 2048;
    cores = 2;
  };

  networking.hostName = "expidus-devvm";
  programs.xwayland.enable = true;
  hardware.opengl.enable = true;

  environment.systemPackages = with pkgs; [ expidus-sdk ];

  nix.nixPath = [
    "nixpkgs=${channelPath}"
    "nixos=${channelPath}"
  ];

  system.defaultChannel = channelPath;

  system.activationScripts.nix = stringAfter [ "etc" "users" ] ''
    install -m 0755 -d /nix/var/nix/{gcroots,profiles}/per-user

    # Subscribe the root user to the NixOS channel by default.
    if [ ! -e "/root/.nix-channels" ]; then
      echo "${channelPath} nixos" > "/root/.nix-channels"
    fi

    # Add the channel to
    if [ ! -e "/home/expidus-devel/.nix-channels" ]; then
      echo "${channelPath} nixos" > "/root/.nix-channels"
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
    displayManager.gdm = {
      enable = true;
      wayland = true;
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

  system.stateVersion = "22.05";
}
