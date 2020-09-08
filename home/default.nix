{ config, pkgs, ...}:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "4ebb7d1715d77269e8bf0eea3c84c8f8e8cd5caa";
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
