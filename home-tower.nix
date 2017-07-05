# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the base configuration that is equal accross all my machines.
      ./base-configuration.nix
    ];

  networking.hostName = "BastiTower-Nixos"; # Define your hostname.

  # Bluetooth
  hardware.bluetooth.enable = true;

  boot.loader.grub.useOSProber = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  environment.systemPackages = with pkgs; [
    steam
  ];

  i18n.consoleKeyMap = "de";
  services.xserver.layout = "de";
}
