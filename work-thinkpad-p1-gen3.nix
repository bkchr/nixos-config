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

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      # Battery feature drivers: 0=disable, 1=enable
      # Default: 1 (all)
      NATACPI_ENABLE = "1";
      TPACPI_ENABLE = "1";
      TPSMAPI_ENABLE = "1";
    };
  };

  services.throttled.enable = true;

  services.fwupd.enable = true;

  services.thinkfan = {
    enable = true;

    sensors = ''
      # Entries here discovered by:
      # find /sys/devices -type f -name "temp*_input"
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp6_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp13_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp3_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp10_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp7_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp14_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp4_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp11_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp8_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp1_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp15_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp5_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp12_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp9_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp2_input
      hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp16_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp6_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp3_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp7_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp4_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp8_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp1_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp5_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp9_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp2_input
      hwmon /sys/devices/pci0000:00/0000:00:1d.0/0000:55:00.0/hwmon/hwmon0/temp3_input
      hwmon /sys/devices/pci0000:00/0000:00:1d.0/0000:55:00.0/hwmon/hwmon0/temp1_input
      hwmon /sys/devices/pci0000:00/0000:00:1d.0/0000:55:00.0/hwmon/hwmon0/temp2_input
      hwmon /sys/devices/virtual/thermal/thermal_zone9/hwmon3/temp1_input
      hwmon /sys/devices/virtual/thermal/thermal_zone10/hwmon4/temp1_input
      hwmon /sys/devices/virtual/thermal/thermal_zone13/hwmon9/temp1_input
    '';

    levels = ''
      (0,     0,      42)
      (1,     40,     47)
      (2,     45,     52)
      (3,     50,     57)
      (4,     55,     62)
      (5,     60,     77)
      (7,     73,     93)
      (127,   85,     32767)
    '';
  };

  services.thermald = {
    enable = true;
    adaptive = true;
  };

  boot.extraModprobeConfig = "options nvidia \"NVreg_DynamicPowerManagement=0x02\"\n";
  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"
    
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"
    
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
    
    # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
    
    # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
  '';
}
