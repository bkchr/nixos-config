{ config, pkgs, ...}:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "cb1ed0d2f324c38290eae180be22e5cfd0c77494";
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
