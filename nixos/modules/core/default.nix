{ pkgs, lib, config, ... }:
{
  imports = [
    ./boot.nix
    ./locale.nix
    ./fonts.nix
    ./audio.nix
  ];
}