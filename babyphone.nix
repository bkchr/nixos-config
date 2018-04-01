{ config, pkgs, ... }:

{
  imports = [
    # Include the base configuration that is equal accross all my machines.
    ./base-configuration.nix
  ];

  networking.hostName = "babyphone";

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelParams = [ "cma=32M" ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];
}
