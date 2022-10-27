args@{ config, lib, pkgs, ... }:
with lib;
let
  inherit (lib) trivial nixpkgsPath;
  base = import (nixpkgsPath + "/nixos/modules/installer/tools/tools.nix") args;

  makeProg = args: pkgs.substituteAll (args // {
    dir = "bin";
    isExecutable = true;
  });

  nixos-build-vms = makeProg {
    name = "nixos-build-vms";
    src = nixpkgsPath + "/nixos/modules/installer/tools/nixos-build-vms/nixos-build-vms.sh";
    inherit (pkgs) runtimeShell;
  };

  nixos-install = makeProg {
    name = "nixos-install";
    src = nixpkgsPath + "/nixos/modules/installer/tools/nixos-install.sh";
    inherit (pkgs) runtimeShell;
    nix = config.nix.package.out;
    path = makeBinPath [
      pkgs.jq
      nixos-enter
    ];
  };

  nixos-rebuild = pkgs.nixos-rebuild.override { nix = config.nix.package.out; };

  nixos-generate-config = makeProg {
    name = "nixos-generate-config";
    src = nixpkgsPath + "/nixos/modules/installer/tools/nixos-generate-config.pl";
    perl = "${pkgs.perl.withPackages (p: [ p.FileSlurp ])}/bin/perl";
    detectvirt = "${config.systemd.package}/bin/systemd-detect-virt";
    btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
    inherit (config.system.nixos-generate-config) configuration desktopConfiguration;
    xserverEnabled = config.services.xserver.enable;
  };

  nixos-option =
    if lib.versionAtLeast (lib.getVersion config.nix.package) "2.4pre"
    then null
    else pkgs.nixos-option;

  nixos-version = makeProg {
    name = "nixos-version";
    src = nixpkgsPath + "/nixos/modules/installer/tools/nixos-version.sh";
    inherit (pkgs) runtimeShell;
    inherit (config.system.nixos) version codeName revision;
    inherit (config.system) configurationRevision;
    json = builtins.toJSON ({
      nixosVersion = config.system.nixos.version;
    } // optionalAttrs (config.system.nixos.revision != null) {
      nixpkgsRevision = config.system.nixos.revision;
    } // optionalAttrs (config.system.configurationRevision != null) {
      configurationRevision = config.system.configurationRevision;
    });
  };

  nixos-enter = makeProg {
    name = "nixos-enter";
    src = nixpkgsPath + "/nixos/modules/installer/tools/nixos-enter.sh";
    inherit (pkgs) runtimeShell;
  };

  expidus-version = makeProg {
    name = "expidus-version";
    src = ./expidus-version.sh;
    inherit (pkgs) runtimeShell;
    inherit (trivial) version codeName release revision;
    json = builtins.toJSON ({
      expidusVersion = trivial.version;
    } // optionalAttrs (trivial.revision != "unknown") {
      expidusRevision = trivial.revision;
    });
  };
in base // {
  config = lib.mkIf (config.nix.enable && !config.system.disableInstallerTools) {
    system.nixos-generate-config.configuration = mkDefault ''
      # Edit this configuration file to define what should be installed on
      # your system.  Help is available in the configuration.nix(5) man page
      # and in the NixOS manual (accessible by running ‘nixos-help’).
      { config, pkgs, ... }:
      {
        imports =
          [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
          ];
      $bootLoaderConfig
        # networking.hostName = "nixos"; # Define your hostname.
        # Pick only one of the below networking options.
        # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
        # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
        # Set your time zone.
        # time.timeZone = "Europe/Amsterdam";
        # Configure network proxy if necessary
        # networking.proxy.default = "http://user:password\@proxy:port/";
        # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
        # Select internationalisation properties.
        # i18n.defaultLocale = "en_US.UTF-8";
        # console = {
        #   font = "Lat2-Terminus16";
        #   keyMap = "us";
        #   useXkbConfig = true; # use xkbOptions in tty.
        # };
      $xserverConfig
      $desktopConfiguration
        # Configure keymap in X11
        # services.xserver.layout = "us";
        # services.xserver.xkbOptions = {
        #   "eurosign:e";
        #   "caps:escape" # map caps to escape.
        # };
        # Enable CUPS to print documents.
        # services.printing.enable = true;
        # Enable sound.
        # sound.enable = true;
        # hardware.pulseaudio.enable = true;
        # Enable touchpad support (enabled default in most desktopManager).
        # services.xserver.libinput.enable = true;
        # Define a user account. Don't forget to set a password with ‘passwd’.
        # users.users.jane = {
        #   isNormalUser = true;
        #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        #   packages = with pkgs; [
        #     firefox
        #     thunderbird
        #   ];
        # };
        # List packages installed in system profile. To search, run:
        # \$ nix search wget
        # environment.systemPackages = with pkgs; [
        #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        #   wget
        # ];
        # Some programs need SUID wrappers, can be configured further or are
        # started in user sessions.
        # programs.mtr.enable = true;
        # programs.gnupg.agent = {
        #   enable = true;
        #   enableSSHSupport = true;
        # };
        # List services that you want to enable:
        # Enable the OpenSSH daemon.
        # services.openssh.enable = true;
        # Open ports in the firewall.
        # networking.firewall.allowedTCPPorts = [ ... ];
        # networking.firewall.allowedUDPPorts = [ ... ];
        # Or disable the firewall altogether.
        # networking.firewall.enable = false;
        # Copy the NixOS configuration file and link it from the resulting system
        # (/run/current-system/configuration.nix). This is useful in case you
        # accidentally delete configuration.nix.
        # system.copySystemConfiguration = true;
        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "${config.system.nixos.release}"; # Did you read the comment?
      }
    '';

    environment.systemPackages = [
      nixos-build-vms
      nixos-install
      nixos-rebuild
      nixos-generate-config
      nixos-version
      nixos-enter
      expidus-version
    ] ++ lib.optional (nixos-option != null) nixos-option;
    system.build = { inherit nixos-install nixos-generate-config nixos-option nixos-rebuild nixos-enter expidus-version; };
  };
}
