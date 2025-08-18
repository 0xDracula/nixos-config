# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  stylix,
  ...
}: let

   sddm-theme = inputs.SilentSDDM.packages.${pkgs.system}.default.override {
    theme = "rei";
   };

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
  ];

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

  networking.networkmanager.enable = true;
  #services.displayManager.sddm.enable = true;
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = sddm-theme.pname;
    extraPackages = sddm-theme.propagatedBuildInputs;
    settings = {
        # required for styling the virtual keyboard
        General = {
          GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
          InputMethod = "qtvirtualkeyboard";
        };
      };
  };
  systemd.tmpfiles.rules = let
    user = "dracula";
    iconPath = ./avatar.jpg;
  in [
    "f+ /var/lib/AccountsService/users/${user}  0600 root root -  [User]\\nIcon=/var/lib/AccountsService/icons/${user}\\n"
    "L+ /var/lib/AccountsService/icons/${user}  -    -    -    -  ${iconPath}"
  ];

  services.desktopManager.plasma6.enable = true;

  # stylix.enable = true;
  # stylix.image = ./modules/stylix/wallpaper.jpg;
  # stylix.cursor = {
  #   package = pkgs.bibata-cursors;
  #   name = "Bibata-Modern-Ice";
  #   size = 24;
  # };
  # stylix.opacity = {
  #   terminal = 0.95;
  #   popups = 95;
  # };
  # stylix.polarity = "dark";
  # stylix.fonts = {
  #   emoji = {
  #     package = pkgs.noto-fonts-color-emoji;
  #     name = "Noto Color Emoji";
  #   };

  #   sizes = {
  #     applications = 12;
  #     desktop = 12;
  #     popups = 12;
  #     terminal = 12;
  #   };
  # };

  services.flatpak.enable = true;
  users.users = {
    dracula = {
      isNormalUser = true;
      extraGroups = ["input" "wheel" "networkmanager" "gamemode"];
    };
  };

  services.printing.enable = true;
  xdg.portal.enable = true;
  services.xserver.xkb = {
    layout = "us";
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    drkonqi
  ];

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
    sddm-theme
    sddm-theme.test
  ];

  qt.enable = true;

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

  system.stateVersion = "25.05";
}
