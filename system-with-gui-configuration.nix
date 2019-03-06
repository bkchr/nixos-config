# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  yakuake_autostart = (pkgs.makeAutostartItem { name = "yakuake"; package = pkgs.yakuake; srcPrefix = "org.kde.";  });
in
{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ./base-configuration.nix
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
     android-studio
     skanlite
     plasma-browser-integration
     vscode
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

  networking.networkmanager.enable = true;

  # Open TCP and UDP port ranges for kdeconnect
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];

  nixpkgs.config = {
    firefox.enablePlasmaBrowserIntegration = true;
    android_sdk.accept_license = true;
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
    ];
  };

  services.teamviewer.enable = true;
}
