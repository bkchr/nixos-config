# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  yakuake_autostart = (pkgs.makeAutostartItem { name = "yakuake"; package = pkgs.yakuake; srcPrefix = "org.kde.";  });
  rust-analyzer = pkgs.rustPlatform.buildRustPackage rec {
    name = "rust-analyzer-${version}";
    version = "ad03e4de185f0f19ae75a8a9c4095ee1b0d82a47";
    src = pkgs.fetchFromGitHub {
      owner = "rust-analyzer";
      repo = "rust-analyzer";
      rev = "${version}";
      sha256 = "0n3bmsbhridq2sbs06ri4cm8ynqid8w1npnmnc8am7izj13xj4k7";
    };

    cargoSha256 = "1p1dg9yy8606z5if7fa523b8myxhixsdd75r9ffaxn7jzcxkz5wz";

    cargoBuildFlags = [ "-p rust-analyzer" ];

    cargoTestFlags = [ "--all" "--exclude xtask" ];

    RUST_SRC_PATH = pkgs.rustPlatform.rustcSrc;

    nativeBuildInputs = [ pkgs.rustfmt ];

    doCheck = false;
  };
  rustAnalyzerVscodeNodePackages =
    import ./rust-analyzer/node-composition.nix {
      inherit (pkgs) nodejs pkgs;
      inherit (pkgs.stdenv.hostPlatform) system;
    };
  rust-analyzer-vscode-node = rustAnalyzerVscodeNodePackages.package.override {
    src = pkgs.stdenv.mkDerivation rec {
      name = "rst-test";
      version = rust-analyzer.version;
      src = pkgs.fetchFromGitHub {
        owner = "rust-analyzer";
        repo = "rust-analyzer";
        rev = "${version}";
        sha256 = "17fv46y42xw427z16dskw05skq460dbmck1dbkr2nr2as2cpz9b5";
      };
      postPatch = ''
        substituteInPlace editors/code/src/config.ts --replace "ra_lsp_server" "${rust-analyzer}/bin/ra_lsp_server"
        substituteInPlace editors/code/package.json --replace "ra_lsp_server" "${rust-analyzer}/bin/ra_lsp_server"
      '';
      installPhase = ''
        mkdir -p $out
        cp -R editors/code/* $out/
      '';
    };
    postInstall = ''npm run compile'';
  };
  rust-analyzer-vscode = pkgs.vscode-utils.buildVscodeExtension rec {
    name = "ra-lsp-${version}";
    vscodeExtUniqueId = "${name}";

    version = rust-analyzer-vscode-node.version;
    src = rust-analyzer-vscode-node;
    sourceRoot = "${rust-analyzer-vscode-node.name}/lib/node_modules/ra-lsp";

    buildPhase = ''
      rm -rf tsconfig.json tslint.json package-lock.json src
    '';
  };
  myvscode = pkgs.vscode-with-extensions.override {
    # When the extension is already available in the default extensions set.
    vscodeExtensions = with pkgs.vscode-extensions; [
      bbenoist.Nix
      llvm-org.lldb-vscode
      vscodevim.vim
      #rust-analyzer-vscode
    ]
    # Concise version from the vscode market place when not available in the default set.
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "dart-code";
        publisher = "Dart-Code";
        version = "3.3.0";
        sha256 = "138l4055wg7dz0lxz0f0x8yhj224339xhvpwd2z6amr31pf0lfqv";
      }
      {
        name = "flutter";
        publisher = "Dart-Code";
        version = "3.3.0";
        sha256 = "0dadrrj45v38303s9f50mbsghkm0y0xz6znmlpa9d4k6w0vbywnq";
      }
      {
        name = "vscode-pull-request-github";
        publisher = "GitHub";
        version = "0.10.0";
        sha256 = "07ii3j0h106xhg3mdy1d08447yx9c4db189h86qsdmdjbygvry8s";
      }
      {
        name = "vscode-direnv";
        publisher = "Rubymaniac";
        version = "0.0.2";
        sha256 = "1gml41bc77qlydnvk1rkaiv95rwprzqgj895kxllqy4ps8ly6nsd";
      }
      {
        name = "one-monokai";
        publisher = "azemoh";
        version = "0.3.7";
        sha256 = "0mv7ibhj66vsp24yy711hlan0rsvfiw5ba8g5x07c48r1nlxm6yj";
      }
      {
        name = "better-toml";
        publisher = "bungcip";
        version = "0.3.2";
        sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
      }
      {
        name = "vscode-wasm";
        publisher = "dtsvet";
        version = "1.2.1";
        sha256 = "1nvfdl1hqm655l60v9x857wyd7jc3jq7g5qigmydzndg6n6jgwjy";
      }
      {
        name = "an-old-hope-theme-vscode";
        publisher = "dustinsanders";
        version = "4.1.0";
        sha256 = "0ik4qm0d742vq1fy8wf56i6bbpcn44g1i3bzx09x30vrzpwddayn";
      }
      {
        name = "tslint";
        publisher = "eg2";
        version = "1.0.44";
        sha256 = "11q8kmm7k3pllwgflsjn20d1w58x3r0vl3i2b32bnbk2gzwcjmib";
      }
      {
        name = "ayu-one-dark";
        publisher = "faceair";
        version = "1.1.1";
        sha256 = "104ab878n0bi2nnwxi7xi7aj2rzbdnbmv14xwcy8hd94gc89zshw";
      }
      {
        name = "asciidoctor-vscode";
        publisher = "joaompinto";
        version = "2.7.6";
        sha256 = "1mklszqcjn9sv6yv1kmbmswz5286mrbnhazs764f38l0kjnrx7qm";
      }
      {
        name = "crates";
        publisher = "serayuzgur";
        version = "0.4.3";
        sha256 = "13wz5pb8l5hx52iapf1ak262v3zcv5d3ll1zvkb2iwj982056k6s";
      }
      {
        name = "vscode-gitweblinks";
        publisher = "reduckted";
        version = "1.4.0";
        sha256 = "0s5iiakpfbn4anbbfw39njlf9rbjaxcf7p9zq8ryx3x0sddw449a";
      }
      {
        name = "code-spell-checker";
        publisher = "streetsidesoftware";
        version = "1.7.18";
        sha256 = "1n9xi08qd8j9vpy50lsh2r73c36y12cw7n87f15rc7fws6ws3x0v";
      }
    ];
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ./base-configuration.nix
    ./home/default.nix
  ];

  hardware = {
     enableAllFirmware = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.dbus.socketActivated = true;

  # List packages installed in system profile. To search by name, run
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     keepassx2
     konversation
     ark
     kdiff3
     yakuake
     yakuake_autostart
     qt5.qtwayland
     kwayland-integration
     okular
     spectacle
     kdeconnect
     # required for kdeconnect
     sshfs-fuse
     firefox
     signal-desktop
     gwenview
     vlc
     kmail
     android-studio
     skanlite
     plasma-browser-integration
     myvscode
     riot-desktop
     zulip

     rust-analyzer
  ];


  # List services that you want to enable:

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    browsing = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # Scanner support
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkbOptions = "eurosign:e";

    # Enable the KDE Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    libinput.enable = true;
    libinput.disableWhileTyping = true;
  };

  # Pulseaudio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  # Open TCP and UDP port ranges for kdeconnect
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];

  nixpkgs.config = {
    firefox.enablePlasmaBrowserIntegration = true;
    android_sdk.accept_license = true;
  };

  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;
  services.syncthing.user = "bastian";
  services.syncthing.dataDir = "/home/bastian/.syncthing";

  programs.adb.enable = true;
  programs.browserpass.enable = true;

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-code-pro
      emacs-all-the-icons-fonts
      noto-fonts-emoji
    ];
  };

  services.teamviewer.enable = true;

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.1.10.20/32" ];
      dns = [ "10.1.1.1" "1.1.1.1" "1.0.0.1" ];
      privateKeyFile = "/home/bastian/.wireguard/parity.key";
      listenPort = 57465;
      mtu = 1360;

      peers = [
        {
          publicKey = "8vH2fqIEbDRBUkwivbwyywwi1xF0U603PcN+3N731zk=";
          allowedIPs = [ "10.1.0.0/16" "10.11.0.0/19" "10.14.0.0/19" "10.200.0.0/19" "10.100.0.0/19" ];
          endpoint = "212.227.252.235:443";
        }
      ];
    };
  };

  #networking.useNetworkd = true;
  #services.resolved.enable = true;
  #boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
  #systemd.network = {
  #  enable = true;
  #  netdevs = {
  #    "10-wg0" = {
  #      netdevConfig = {
  #        Kind = "wireguard";
  #        MTUBytes = "1360";
  #        Name = "wg0";
  #      };
  #      # See also man systemd.netdev
  #      extraConfig = ''
  #        [WireGuard]
  #        # Currently, the private key must be world readable, as the resulting netdev file will reside in the Nix store.
  #        PrivateKey=aOiVaMSB+hKMjUPEbmULe3gpablGJdcqTQtTfuZ9hkI=
  #        ListenPort=57465

  #        [WireGuardPeer]
  #        PublicKey=8vH2fqIEbDRBUkwivbwyywwi1xF0U603PcN+3N731zk=
  #        AllowedIPs=10.1.1.0/24
  #        Endpoint=212.227.252.235:443
  #      '';
  #    };
  #  };
  #  networks = {
  #    # See also man systemd.network
  #    "10-wg0".extraConfig = ''
  #      [Match]
  #      Name=wg0

  #      [Network]
  #      DNS=10.1.1.1
  #      DNS=1.1.1.1
  #      DNS=1.0.0.1

  #      [Address]
  #      Address=10.1.10.20/32

  #      [Route]
  #      Destination = 10.1.1.0/24
  #    '';
  #  };
  #};
}
