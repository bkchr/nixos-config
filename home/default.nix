{ config, pkgs, ...}:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "d64fff1fe067f18402861769ce1b90f8a34e9000";
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
