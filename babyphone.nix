{ config, pkgs, ... }:

let
  server = pkgs.callPackage /home/bastian/projects/private/babyphone_app/babyphone-server.nix {};
in
{
  imports = [
    # Include the base configuration that is equal accross all my machines.
    ./base-configuration.nix
  ];

  networking.hostName = "babyphone";

  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    start_x=1
    gpu_mem=256
  '';
  services.nixosManual.enable = false;

  boot.kernelParams = [ "cma=32M" ];
  # Load the camera kernel module by default
  boot.kernelModules = [ "bcm2835-v4l2" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
     name = "broadcom-rpi3-extra";
     src = pkgs.fetchurl {
     url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/54bab3d/brcm80211/brcm/brcmfmac43430-sdio.txt";
     sha256 = "19bmdd7w0xzybfassn7x4rb30l70vynnw3c80nlapna2k57xwbw7";
     };
     phases = [ "installPhase" ];
     installPhase = ''
     mkdir -p $out/lib/firmware/brcm
     cp $src $out/lib/firmware/brcm/brcmfmac43430-sdio.txt
     '';
     })
  ];

  # Enable pulseaudio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  boot.kernelPackages = pkgs.linuxPackages_testing;

  # Enable the networkmanager
  networking.networkmanager.enable = true;
  #environment.noXlibs = true;

  # Open the babyphone server port for local reachability
  networking.firewall.allowedUDPPorts = [ 22222 ];

  services.sshd.enable = true;

  users.extraUsers.babyphone = {
    name = "babyphone";
    createHome = true;
    home = "/var/lib/babyphone";
    extraGroups = [ "networkmanager" "video" "audio" ];
  };

  systemd.services.babyphone-server =
    let
      client_ca_path = "/home/bastian/projects/private/babyphone_app/certs";
      server_ca_path = "/home/bastian/projects/private/carrier/test_certs/trusted_bearer_cas";
    in
    {
      description = "Babyphone Server";

      preStart = ''
        cp -fR ${client_ca_path} /var/lib/babyphone/client_ca_path
        cp -fR ${server_ca_path} /var/lib/babyphone/server_ca_path
      '';

      environment = {
        RUST_LOG = "info";
        RUST_BACKTRACE = "1";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${server}/bin/babyphone-server --client_ca_path /var/lib/babyphone/client_ca_path --server_ca_path /var/lib/babyphone/server_ca_path";
        Restart = "always";
        User = "babyphone";
      };

      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
    };
}
