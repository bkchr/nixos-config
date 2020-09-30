# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  yakuake_autostart = (pkgs.makeAutostartItem { name = "yakuake"; package = pkgs.yakuake; srcPrefix = "org.kde.";  });
  rust-analyzer = pkgs.rustPlatform.buildRustPackage rec {
    name = "rust-analyzer-${version}";
    version = "4ddb8124b01a04adcc7d42444f7ca8d377bb60ae";
    src = pkgs.fetchFromGitHub {
      owner = "rust-analyzer";
      repo = "rust-analyzer";
      rev = "${version}";
      sha256 = "0cp0vpds13jci3cc508chx8v3dybq50cix7kszzmazzkv9vghnmn";
    };

    cargoSha256 = "0yg3s3jbg71amk8fwrrvkbic4vhq7n66b153xsvsss45j9ik45jw";

    cargoBuildFlags = [ "-p rust-analyzer" ];

    cargoTestFlags = [ "--all" "--exclude xtask" ];

    RUST_SRC_PATH = pkgs.rustPlatform.rustcSrc;

    nativeBuildInputs = [ pkgs.rustfmt ];

    doCheck = false;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ./base-configuration.nix
    ./home/default.nix
  ];

  hardware = {
     enableAllFirmware = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.dbus.socketActivated = true;

  # List packages installed in system profile. To search by name, run
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     keepassx2
     konversation
     ark
     kdiff3
     yakuake
     yakuake_autostart
     qt5.qtwayland
     kwayland-integration
     okular
     spectacle
     kdeconnect
     # required for kdeconnect
     sshfs-fuse
     firefox
     signal-desktop
     gwenview
     vlc
     kmail
     kate
     android-studio
     skanlite
     plasma-browser-integration
     element-desktop
     thunderbird-78
     spotify

     rust-analyzer

     # Zsa/ergodox
     wally-cli

     # Emacs
     sqlite
     graphviz
  ];


  # List services that you want to enable:

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    browsing = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # Scanner support
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkbOptions = "eurosign:e";

    # Enable the KDE Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    libinput.enable = true;
    libinput.disableWhileTyping = true;
  };

  # Pulseaudio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  # Open TCP and UDP port ranges for kdeconnect
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];

  nixpkgs.config = {
    firefox.enablePlasmaBrowserIntegration = true;
    android_sdk.accept_license = true;

    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;
  services.syncthing.user = "bastian";
  services.syncthing.dataDir = "/home/bastian/.syncthing";

  programs.adb.enable = true;
  programs.browserpass.enable = true;

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-code-pro
      emacs-all-the-icons-fonts
      noto-fonts-emoji
    ];
  };

  services.teamviewer.enable = true;

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.1.10.20/32" ];
      dns = [ "10.1.1.1" "1.1.1.1" "1.0.0.1" ];
      privateKeyFile = "/home/bastian/.wireguard/parity.key";
      listenPort = 57465;
      mtu = 1360;

      peers = [
        {
          publicKey = "8vH2fqIEbDRBUkwivbwyywwi1xF0U603PcN+3N731zk=";
          allowedIPs = [ "10.1.0.0/16" "10.11.0.0/19" "10.14.0.0/19" "10.200.0.0/19" "10.100.0.0/19" ];
          endpoint = "212.227.252.235:443";
        }
      ];
    };
  };

  hardware.keyboard.zsa.enable = true;
}
