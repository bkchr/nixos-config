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

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/b1096ab1-079e-44b3-93ac-f502a1b9d168";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "BastiDell-Nixos"; # Define your hostname.

  # Bluetooth
  hardware.bluetooth.enable = true;

  powerManagement.powertop.enable = true;

  services.xserver = {
    videoDrivers = [ "modesetting" ];
  };
  services.sshd.enable = false;

  environment.systemPackages = with pkgs; [
    zoom-us
    steam
  ];

  # Enable 32bit support for Steam
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;
}
