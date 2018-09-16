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

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/b1096ab1-079e-44b3-93ac-f502a1b9d168";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  networking.hostName = "BastiDell-Nixos"; # Define your hostname.

  # Bluetooth
  hardware.bluetooth.enable = true;

  powerManagement.powertop.enable = true;

  services.xserver = {
    videoDrivers = [ "modesetting" ];
  };

  services.i8kmon = {
    enable = true;
    state0 = "{0 0} \-1 60 \-1 60";
    state1 = "{1 1} 50 90 60 90";
    state2 = "{1 1} 80 100 80 100";
    state3 = "{1 1} 110 128 110 128";
    leftspeed = "0 1000 2000 3000";
    rightspeed = "0 1000 2000 3000";
  };

  services.sshd.enable = false;
}
