# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let


 in {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./modules
    ./hardware-configuration.nix
    inputs.winboat.nixosModules.default
  ];
  qt = {
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      trusted-users = [ "root" "dracula" ];
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

  };
  services.winboat.enable = true;
  boot.kernelParams = ["resume_offset=77438976"];
  boot.resumeDevice = "/dev/disk/by-label/root";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  swapDevices = [
   {
     device ="/var/lib/swapfile";
     size = 16 * 1024;
   }
  ];

  networking.hostName = "nixos";
  #services.xserver.displayManager.gdm.enable = true;
  networking.networkmanager.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.enable = true;

  systemd.tmpfiles.rules = let
    user = "dracula";
    iconPath = ./avatar.jpg;
  in [
    "f+ /var/lib/AccountsService/users/${user}  0600 root root -  [User]\\nIcon=/var/lib/AccountsService/icons/${user}\\n"
    "L+ /var/lib/AccountsService/icons/${user}  -    -    -    -  ${iconPath}"
  ];
  virtualisation.docker = {
    enable = true;
  };

  #services.open-webui.enable = true;
  services.flatpak.enable = true;
  users.users = {
    dracula = {
      isNormalUser = true;
      extraGroups = ["input" "wheel" "networkmanager" "gamemode" "docker"];
    };
  };

  services.printing.enable = true;
  services.xserver.xkb = {
    layout = "us";
  };
  security.polkit.enable = true;
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    python3
    python3Packages.pip
    heroic
    mangohud
    protonup-qt
    lutris
    gtk2
    gtk3
    gtk4
    gnome-tweaks
    bibata-cursors
    wireguard-tools
    protonvpn-gui
    ffmpeg-full
    hunspell
    hunspellDicts.en_US
    #xdg-desktop-portal-gnome
    flameshot
    quickemu
    anydesk
    gamemode
    bootdev-cli
    inputs.matugen.packages.${system}.default
    libnotify
    dialog
    freerdp3
    iproute2
    netcat-openbsd
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    cachix
    brightnessctl
    quickshell
    material-icons
    material-symbols
    inter
    fira-code

    ddcutil
    libsForQt5.qt5ct
    kdePackages.qt6ct
    inputs.dms-cli.packages.${pkgs.system}.default
    inputs.dgop.packages.${pkgs.system}.dgop
    cava
    khal
    gammastep
    nautilus
    cabextract
    emacs-gtk
    glib
    gnome-themes-extra
    cliphist
    papirus-icon-theme
    kdePackages.polkit-kde-agent-1
    niriswitcher
  ];
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  qt.enable = true;
  xdg.mime.defaultApplications = {
    "application/pdf" = "okularApplication_pdf.desktop";
  };
  services.tor = {
    enable = true;
    client.enable = true;
    client.dns.enable = true;
    torsocks.enable = true;
  };
  programs.dconf.enable = true;
  virtualisation.waydroid.enable = true;
  services.playerctld.enable = true;
  services.cloudflare-warp.enable = true;
  systemd.user.services.warp-taskbar = {
    enable = false;
    wantedBy = lib.mkForce [ ]; # forcibly clears wantedBy
    unitConfig = {
      ConditionPathExists = "/nonexistent"; # optional extra block to ensure it can't run
    };
  };
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
  system.stateVersion = "25.05";
}
