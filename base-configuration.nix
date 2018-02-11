# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  user = {
    isNormalUser = true;
    home = "/home/bastian";
    description = "Bastian Köcher";
    # grant access to sudo and to the network
    extraGroups = [ "wheel" "networkmanager" "docker" "adbusers" "scanner" "lp" ];
    uid = 1000;
  };
  yakuake_autostart = (pkgs.makeAutostartItem { name = "yakuake"; package = pkgs.yakuake; srcPrefix = "org.kde.";  });
in
{
  nix.nixPath = [
      "nixpkgs=/home/bastian/projects/nixos/nixos-config/nixpkgs"
      "nixos=/home/bastian/projects/nixos/nixos-config/nixpkgs/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "nixpkgs-overlays=/home/bastian/projects/nixos/nixos-config/overlays"
    ];
 
  nixpkgs.overlays = [ (import /home/bastian/projects/nixos/nixos-config/overlays) ];

  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  hardware = {
     enableAllFirmware = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #Select internationalisation properties.
  i18n = {
     consoleFont = "Lat2-Terminus16";
     defaultLocale = "en_US.UTF-8";
  };

  # Timesync
  services.timesyncd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Build every package in a sandbox
  nix.useSandbox = true;

  # Use all available cores for building
  nix.buildCores = 0;

  # List packages installed in system profile. To search by name, run
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     emacs
     git
     vim
     keepassx2
     konversation
     aspell
     aspellDicts.en
     aspellDicts.de
     ark
     unzip
     hexedit
     powertop
     autojump
     oh-my-zsh
     wget
     iw
     kdiff3
     direnv
     yakuake
     yakuake_autostart
     htop
     qt5.qtwayland
     psmisc
     okular
     pass
     ntfs3g
     spectacle
     ripgrep
     kdeconnect
     # required for kdeconnect
     sshfs-fuse

     # Mozilla Overlay
     latest.firefox-beta-bin

     signal-desktop

     gwenview
     vlc

     ntfs3g
     kmail
     android-studio
     skanlite
  ];


  # List services that you want to enable:

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
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

  networking.networkmanager.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bastian = user;

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  # Pulseaudio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # ZSH
  programs.zsh.enable = true;

  programs.zsh.interactiveShellInit = ''
    export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

    # Customize your oh-my-zsh options here
    ZSH_THEME="spaceship"
    plugins=(git rust cargo docker emacs github gitignore systemd zsh-autosuggestions)

    source "$(autojump-share)/autojump.zsh"

    source $ZSH/oh-my-zsh.sh

    SPACESHIP_DOCKER_SHOW=false

    eval "$(direnv hook zsh)"
  '';

  programs.zsh.promptInit = ""; # Clear this to avoid a conflict with oh-my-zsh
  programs.zsh.enableAutosuggestions=true;

  # Docker
  virtualisation.docker.enable = true;

  # Open UDP port for tftp server
  networking.firewall.allowedUDPPorts = [ 69 ];

  # Open TCP and UDP port ranges for kdeconnect
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];

  # Set google as default nameserver
  networking.nameservers = [ "8.8.8.8" ];

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

  systemd.user.services.emacs.enable = true;

  nixpkgs.config = {
    # I want unfree packages
    allowUnfree = true;

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

      oh-my-zsh =
        let
          spaceshiptheme = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/a9819c528904000f5d246d3ed3c7514a30cf495a/spaceship.zsh";
            sha256 = "d469b6843a09152c56ecb01fd589adf194ba1edda58f7f0887b387ea06561408";
          };
        in
          pkgs.lib.overrideDerivation pkgs.oh-my-zsh (attrs: {
            # Install spaceship theme
            installPhase = [
              attrs.installPhase
                ''outdir=$out/share/oh-my-zsh
                  chmod -R +w $outdir
                  mkdir -p $outdir/custom/themes
                  cp -v ${spaceshiptheme} $outdir/custom/themes/spaceship.zsh-theme
                  mkdir -p $outdir/custom/plugins/nix
                  cp -R ${pkgs.nix-zsh-completions}/share/zsh/site-functions/* $outdir/custom/plugins/nix/
                ''
            ];
          });
    };

  };

  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;
  services.syncthing.user = "bastian";
  services.syncthing.dataDir = "${user.home}/.syncthing";

  programs.adb.enable = true;

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-code-pro
    ];
  };

  environment.sessionVariables = {
    # set vim as global editor
    EDITOR = "${pkgs.vim}/bin/vim";
  };

  services.teamviewer.enable = true;
}
