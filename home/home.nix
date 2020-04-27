{ config, pkgs, ...}:

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
        rm -rf $HOME/.cache/doom-emacs
        $HOME/.emacs.d/bin/doom --yes --localdir $HOME/.cache/doom-emacs update
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
}
