{
  nix-config,
  config,
  pkgs,
  ...
}:

let
  opacity = 0.95;
  fontSize = 12;
in
{
  stylix = {
    enable = true;
    image = ./wallpaper.jpg;
    polarity = "dark";

    opacity = {
      terminal = opacity;
      popups = opacity;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts = {

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = fontSize;
        desktop = fontSize;
        popups = fontSize;
        terminal = fontSize;
      };
    };
  };
}

