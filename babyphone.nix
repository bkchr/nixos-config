{ config, pkgs, ... }:

let
  server = pkgs.callPackage /home/bastian/projects/private/babyphone_app/nix/babyphone-server.nix {};
  kernel = pkgs.linuxPackages_rpi.kernel;
  seeed-voicecard = pkgs.stdenv.mkDerivation rec {
    name = "seeed-voicecard";

    src = pkgs.fetchFromGitHub {
      owner = "respeaker";
      repo = "seeed-voicecard";
      rev = "b98fce84e0e45eaa85ef08c4b5dfe962b49a5149";
      sha256 = "0imsygrs718p305pb3rjgw29cqfx22lkvzbg7myi6cbdxl1nzzi1";
    };

    #preConfigure = ''
    #  substituteInPlace Makefile --replace "snd-soc-wm8960-objs := wm8960.o" ""
    #  substituteInPlace Makefile --replace "obj-m += snd-soc-wm8960.o" ""
    #'';

    KERNELDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

    NIX_CFLAGS = ["-Wno-error=cpp"];

    nativeBuildInputs = [ pkgs.perl ] ++ kernel.moduleBuildDependencies;

    buildPhase = "make -C $KERNELDIR M=$(pwd) modules";
    installPhase = ''
      mkdir -p $out/lib/modules/${kernel.modDirVersion}/sound/soc/codecs
      mkdir -p $out/lib/modules/${kernel.modDirVersion}/sound/soc/bcm

      cp snd-soc-wm8960.ko $out/lib/modules/${kernel.modDirVersion}/sound/soc/codecs
      cp snd-soc-ac108.ko $out/lib/modules/${kernel.modDirVersion}/sound/soc/codecs
      cp snd-soc-seeed-voicecard.ko $out/lib/modules/${kernel.modDirVersion}/sound/soc/bcm
    '';
  };
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

  boot.kernelParams = [ "cma=32M" "console=ttyS1,115200n8" ];
  # Load the camera kernel module by default
  boot.kernelModules = [ "bcm2835-v4l2" "snd_bcm2835" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  hardware.enableRedistributableFirmware = true;

  # Enable sound
  sound.enable = true;
  sound.extraConfig = ''
    pcm.!default {
        type hw
        card 1
    }

    ctl.!default {
        type hw
        card 1
    }
  '';

  # Enable the networkmanager
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.enableIPv6 = false;
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
        RUST_LOG = "info,picoquic=trace";
        RUST_BACKTRACE = "1";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${server}/bin/babyphone-server --client_ca_path /var/lib/babyphone/client_ca_path --server_ca_path /var/lib/babyphone/server_ca_path --settings /var/lib/babyphone/settings.json";
        Restart = "always";
	RestartSec = "1s";
        User = "babyphone";
      };

      unitConfig = {
        StartLimitIntervalSec = "0";
      };

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "default.target" ];
      #onFailure = [ "systemd-reboot.service" ];
    };

  fonts.fontconfig.penultimate.enable = false;
  #boot.kernelPackages = pkgs.linuxPackages_rpi3;
  #boot.extraModulePackages = [ seeed-voicecard ];
}
