{ config, pkgs, ...}:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "5c1e7349bbd9b51fe41ea96b67c380feef996b90";
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
}
