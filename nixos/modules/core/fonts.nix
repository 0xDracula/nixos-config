{ config, lib, pkgs, ... }:
{
  fonts = {
   enableDefaultPackages = true;

   packages = with pkgs; [
     noto-fonts
     noto-fonts-cjk-sans
     noto-fonts-emoji
     liberation_ttf
     fira-code
     fira-code-symbols
     mplus-outline-fonts.githubRelease
     dina-font
     proggyfonts
     rubik
     dejavu_fonts
     adwaita-fonts
   ];
  };
}
