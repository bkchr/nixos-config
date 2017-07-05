# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the base configuration that is equal accross all my machines.
      ./base-configuration.nix
    ];

  networking.hostName = "BastiMacBook-Nixos"; # Define your hostname.

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "modesetting" ];
    resolutions = [{ x = 1920; y = 1080; }] ;

    displayManager.sessionCommands = 
      ''
        xrandr --newmode "1920x1200_60.00"  193.25  1920 2056 2256 2592  1200 1203 1209 1245 -hsync +vsync
        xrandr --addmode eDP-1 "1920x1200_60.00"
      '';
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Service for disabling the mac fn behavior
  systemd.services.mac-keyboard = {
     description = "Mac-Keyboard Daemon";
     serviceConfig = {
       Type = "oneshot";
       ExecStart = "/bin/sh -c \"echo 2 > /sys/module/hid_apple/parameters/fnmode\"";
       ExecStop = "/bin/sh -c \"echo 1 > /sys/module/hid_apple/parameters/fnmode\"";
       RemainAfterExit = "yes";
     };
     wantedBy = [ "multi-user.target" ];
  }; 

  #powerManagement.powertop.enable = true;

  i18n.consoleKeyMap = "de";
  services.xserver.layout = "de";
}
