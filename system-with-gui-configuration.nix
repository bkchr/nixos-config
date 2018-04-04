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

  # List packages installed in system profile. To search by name, run
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     emacs
     keepassx2
     konversation
     ark
     kdiff3
     yakuake
     yakuake_autostart
     qt5.qtwayland
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
     ripgrep
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
 
  # Open UDP port for tftp server
  networking.firewall.allowedUDPPorts = [ 69 ];

  # Open TCP and UDP port ranges for kdeconnect
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];

  systemd.user.services.emacs = {
    description = "Emacs Daemon";
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.zsh}/bin/zsh -c \"${pkgs.emacs}/bin/emacs --daemon\"";
      ExecStop = "${pkgs.zsh}/bin/zsh -c \"${pkgs.emacs}/bin/emacsclient --eval \\\"(kill-emacs)\\\"\"";
      Restart = "always";
    };

    environment = {
      GTK_DATA_PREFIX = config.system.path;
      SSH_AUTH_SOCK = "%t/ssh-agent";
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " config.environment.profiles}";
      TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
      ASPELL_CONF = "dict-dir /run/current-system/sw/lib/aspell";
      HOME = "/home/bastian/";
    };

    path = with pkgs; [direnv];

    wantedBy = [ "default.target" ];
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      # Define my own Emacs
      emacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
        withGTK3 = true;
        withGTK2 = false;
      }) (attrs: {
        # "Improve" the emacs.desktop to point to the emacsclient
        postInstall = (attrs.postInstall or "") + ''
          sed -i 's/emacs \%F/emacsclient -c -a "" \%F/g' $out/share/applications/emacs.desktop
        '';
      });
    };

  };

  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;
  services.syncthing.user = "bastian";
  services.syncthing.dataDir = "/home/bastian/.syncthing";

  programs.adb.enable = true;

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
