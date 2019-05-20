# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  yakuake_autostart = (pkgs.makeAutostartItem { name = "yakuake"; package = pkgs.yakuake; srcPrefix = "org.kde.";  });
  myvscode = pkgs.vscode-with-extensions.override {
    # When the extension is already available in the default extensions set.
    vscodeExtensions = with pkgs.vscode-extensions; [
      bbenoist.Nix
      llvm-org.lldb-vscode
      vscodevim.vim
    ]
    # Concise version from the vscode market place when not available in the default set.
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "one-monokai";
        publisher = "azemoh";
        version = "0.3.7";
        sha256 = "0mv7ibhj66vsp24yy711hlan0rsvfiw5ba8g5x07c48r1nlxm6yj";
      }
      {
        name = "better-toml";
        publisher = "bungcip";
        version = "0.3.2";
        sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
      }
      {
        name = "dart-code";
        publisher = "Dart-Code";
        version = "2.25.0";
        sha256 = "1qh85174npip3hndrvm1ysraq6vz7yslr4286k8nnwymrnzml4pk";
      }
      {
        name = "flutter";
        publisher = "Dart-Code";
        version = "2.25.0";
        sha256 = "0bpaz57d2bdc8kv56m7p6p4ms6qziknirc4xa70i5dc1b0jdk74m";
      }
      {
        name = "vscode-wasm";
        publisher = "dtsvet";
        version = "1.2.1";
        sha256 = "1nvfdl1hqm655l60v9x857wyd7jc3jq7g5qigmydzndg6n6jgwjy";
      }
      {
        name = "an-old-hope-theme-vscode";
        publisher = "dustinsanders";
        version = "3.2.1";
        sha256 = "020h5iqh3d6qsqyv4ac7z35pyrwd1sjkh0b9w2b51q8qlc5q4d9x";
      }
      {
        name = "tslint";
        publisher = "eg2";
        version = "1.0.43";
        sha256 = "0p0lvkip083vx1y5p53ksy9457x76ylxlc2kf7zdb09vqm6ss8z3";
      }
      {
        name = "ayu-one-dark";
        publisher = "faceair";
        version = "1.1.1";
        sha256 = "104ab878n0bi2nnwxi7xi7aj2rzbdnbmv14xwcy8hd94gc89zshw";
      }
      {
        name = "vscode-pull-request-github";
        publisher = "GitHub";
        version = "0.6.0";
        sha256 = "05csvsbbc6g43c6zkyh36vzr9a47gk2vdyvi1kvz7vcfpnmp4459";
      }
      {
        name = "asciidoctor-vscode";
        publisher = "joaompinto";
        version = "2.4.0";
        sha256 = "0wkajfcakl1iqfcf58j05drcgvr5fhqrqzayylxzzvgnn4x172d4";
      }
      {
        name = "vscode-typescript-tslint-plugin";
        publisher = "ms-vscode";
        version = "1.0.0";
        sha256 = "155frrf8fs0c6sgs532cxgwvxzinkgg4k0ywsbl7zzjip8qqmm0g";
      }
      {
        name = "vscode-direnv";
        publisher = "Rubymaniac";
        version = "0.0.2";
        sha256 = "1gml41bc77qlydnvk1rkaiv95rwprzqgj895kxllqy4ps8ly6nsd";
      }
      {
        name = "rust";
        publisher = "rust-lang";
        version = "0.6.1";
        sha256 = "0f66z6b374nvnrn7802dg0xz9f8wq6sjw3sb9ca533gn5jd7n297";
      }
    ];
  };
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
     myvscode
     riot-desktop
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
