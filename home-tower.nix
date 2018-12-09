# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the base configuration that is equal accross all my machines.
    ./system-with-gui-configuration.nix
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
  ];

  networking.hostName = "BastiTower-Nixos"; # Define your hostname.

  # Bluetooth
  hardware.bluetooth.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  environment.systemPackages = with pkgs; [
    steam
    teamspeak_client
    playonlinux
    wineStaging
    vagrant
    virtualbox
  ];

  services.sshd.enable = true;
}
