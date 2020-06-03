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
    extraGroups = [ "wheel" "networkmanager" "docker" "adbusers" "scanner" "lp" "audio" "video" "input" "plugdev" ];
    uid = 1000;
  };
  # Make pass use gpg2 and add `pass-otp`
  pass = (pkgs.pass.override { gnupg = pkgs.gnupg22; }).withExtensions (ext: [ext.pass-otp]);
in
{
  imports = [
    ./modules/zsa
  ];

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
         hostName = "aarch64.nixos.community";
         maxJobs = 96;
         sshKey = "/root/nixos";
         sshUser = "bkchr";
         system = "aarch64-linux";
         supportedFeatures = [ "big-parallel" ];
      }
    ];
    nixPath = [
      "nixpkgs=/home/bastian/projects/nixos/nixos-config/nixpkgs"
      "nixos=/home/bastian/projects/nixos/nixos-config/nixpkgs/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "nixpkgs-overlays=/home/bastian/projects/nixos/nixos-config/overlays"
    ];
  };

  nixpkgs.overlays = [ (import /home/bastian/projects/nixos/nixos-config/overlays) ];

  hardware = {
     enableAllFirmware = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  #Select internationalisation properties.
  console.font = "Lat2-Terminus16";
  i18n.defaultLocale = "en_US.UTF-8";

  # Timesync
  services.timesyncd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Build every package in a sandbox
  nix.useSandbox = true;

  # Use all available cores for building
  nix.buildCores = 0;

  # List packages installed in system profile. To search by name, run
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     git
     vim
     aspell
     aspellDicts.en
     aspellDicts.de
     unzip
     hexedit
     powertop
     fasd
     wget
     iw
     direnv
     htop
     psmisc
     ntfs3g
     ripgrep

     pass
     gnupg22
     yubikey-personalization
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  # Enable api for programs to communicate with smartcards
  services.pcscd.enable = true;

  # List services that you want to enable:

  # Enable Avahi
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    nssmdns = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bastian = user;

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";

  # ZSH
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.plugins = ["git" "rust" "cargo" "docker" "emacs" "github" "gitignore" "systemd" "vi-mode" "fasd" ];
    ohMyZsh.theme = "spaceship";
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      SPACESHIP_DOCKER_SHOW=false
      eval "$(direnv hook zsh)"
    '';
  };

  # Docker
  virtualisation.docker.enable = true;

  # Set google as default nameserver
  networking.nameservers = [ "8.8.8.8" ];

  nixpkgs.config = {
    # I want unfree packages
    allowUnfree = true;

    packageOverrides = pkgs: {
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

  environment.sessionVariables = {
    # set vim as global editor
    EDITOR = "${pkgs.vim}/bin/vim";
  };

  programs.gnupg = {
    package = pkgs.gnupg22;
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "p7zip-16.02"
  ];
}
