# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the base configuration that is equal accross all my machines.
      ./base-configuration.nix
    ];

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/nvme0n1p3";
      preLVM = true;
    }
  ];

  boot.extraModprobeConfig = ''options thinkpad_acpi fan_control=1'';

  networking.hostName = "BastiTP-Nixos"; # Define your hostname.

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "modesetting" ];
    resolutions = [{ x = 1920; y = 1080; }] ;

    displayManager.sessionCommands =
      ''
        modeline=$(cvt -v 1920 1080 | grep Modeline | sed -e "s/Modeline //")
        xrandr --newmode $modeline
        modename=$(echo $modeline | awk '{ print $1; }')
        xrandr --addmode eDP-1 $modename
      '';
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  powerManagement.powertop.enable = true;

  services.sshd.enable = true;
}
