# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports = [
    # Include the base configuration that is equal accross all my machines.
    ./system-with-gui-configuration.nix
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
  ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "BastiP1-Nixos"; # Define your hostname.

  # Bluetooth
  hardware.bluetooth.enable = true;

  powerManagement.powertop.enable = true;

  services.sshd.enable = false;

  environment.systemPackages = with pkgs; [
    zoom-us
    steam
    nvidia-offload
  ];

  # Enable 32bit support for Steam
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Enable audio power saving for Intel HDA, AC97 devices (timeout in secs).
      # A value of 0 disables, >=1 enables power saving (recommended: 1).
      # Default: 0 (AC), 1 (BAT)
      SOUND_POWER_SAVE_ON_AC = "0";
      SOUND_POWER_SAVE_ON_BAT = "1";

      # Runtime Power Management for PCI(e) bus devices: on=disable, auto=enable.
      # Default: on (AC), auto (BAT)
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # Battery feature drivers: 0=disable, 1=enable
      # Default: 1 (all)
      NATACPI_ENABLE = "1";
      TPACPI_ENABLE = "1";
      TPSMAPI_ENABLE = "1";
    };
  };

  services.fwupd.enable = true;
}
