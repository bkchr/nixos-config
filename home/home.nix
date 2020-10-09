{ config, pkgs, ...}:

let
  cargo_remote = pkgs.callPackage ./cargo-remote.nix {};
in
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Emacs and recommended packages
    emacs
    coreutils
    fd
    clang
    editorconfig-core-c
    multimarkdown

    cargo_remote
  ];
  
  # Enable lorri
  services.lorri.enable = true;

  # project/parity
  home.file."projects/parity/shell.nix".source = ./files/projects/parity/shell.nix;
  home.file."projects/parity/.envrc" = {
    source = ./files/projects/parity/.envrc;
    onChange = ''
      ${pkgs.direnv}/bin/direnv allow $HOME/projects/parity/.envrc
    '';
  };

  # Doom Emacs
  home.file = {
    ".emacs.d" = {
      source = ./files/.emacs.d;
      recursive = true;
      onChange = ''
        $HOME/.emacs.d/bin/doom --yes sync
        $HOME/.emacs.d/bin/doom --yes sync -u
      '';
    };

    ".doom.d" = {
      source = ./files/.doom.d;
      recursive = true;
    };
  };

  # Generate the keyfile for wireguard 
  home.file.".wireguard/parity.key.generate" = {
    text = "nothing";
    onChange = ''
      ${pkgs.pass}/bin/pass Work/Parity/wireguard > $HOME/.wireguard/parity.key
    '';
  };

  programs.git = {
    enable = true;

    userEmail = "git@kchr.de";
    userName = "Bastian Köcher";
    
    # Enable the delta syntax highlighter
    delta.enable = true;

    signing.key = "CBC7115E48718492";

    extraConfig = {
      pull.rebase = "false";
    };
  };

  # Pass configs
  services.password-store-sync.enable = true;
  programs.password-store = {
    enable = true;
    package = (pkgs.pass.override { gnupg = pkgs.gnupg22; }).withExtensions (ext: [ext.pass-otp]);
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    };
  };

  # Enable unfree packages for nix-shell
  home.file.".config/nixpkgs/config.nix" = {
    text = "{ allowUnfree = true; }";
  };

  # Add cargo remote config
  home.file.".config/cargo-remote/cargo-remote.toml" = {
    text = ''
      remote = "bkchr@10.1.1.54"
    '';
  };
}
