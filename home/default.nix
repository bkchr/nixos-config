{ config, pkgs, ...}:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "e7b1491fb8dfb1d2bdb90432312e88d03c8d803d";
  };
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager = {
    useUserPackages = true;
    users.bastian = (import ./home.nix);
    useGlobalPkgs = true;
  };

  # Find a better way to set this..
  environment.variables.DOOMLOCALDIR = "~/.cache/doom-emacs/";
}
