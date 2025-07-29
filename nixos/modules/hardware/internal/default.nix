{ pkgs, lib, config, ... }:
{
  imports = [
    ./hardware.nix
    ./gpu.nix
  ];
}
