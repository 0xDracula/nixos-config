{ config, pkgs, ... }:

let
  # Out-of-store symlinks require absolute paths when using a flake config. This
  # is because relative paths are expanded after the flake source is copied to
  # a store path which would get us read-only store paths.
  dir = "/home/dracula/nixos/home/matugen";
in
{
  xdg.configFile = {
    matugen.source = config.lib.file.mkOutOfStoreSymlink "${dir}/matugen-config";
    #swaync.source = config.lib.file.mkOutOfStoreSymlink "${dir}/swaync";
  };

  #services.blueman-applet.enable = true;
  #services.network-manager-applet.enable = true;

  # Use Gnome Keyring as SSH agent
  #services.gnome-keyring = {
    #enable = true;
    #components = [ "pkcs11" "secrets" "ssh" ];
  #};
  #home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";


  # OSD for volume, brightness changes
  #services.swayosd.enable = true;
  #systemd.user.services.swayosd = {
    # Adjust swayosd restart policy - it's failing due to too many restart
    # attempts when resuming from sleep
    #Unit.StartLimitIntervalSec = lib.mkForce 1;
  #};
}
