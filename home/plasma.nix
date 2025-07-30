{ ... }:
{
  programs.plasma = {
    enable = true;
    shortcuts = {
      "services/org.flameshot.Flameshot.desktop" = {
        "Capture" = "Meta+Shift+S";
      };
    };
    input = {
      touchpads = [
        {
          enable = true;
          vendorId = "04f3";
          productId = "327e";
          name = "ELAN06FA:00 04F3:327E Touchpad";
          naturalScroll = true;
        }
      ];
      keyboard = {
        numlockOnStartup = "on";
        options = [ "grp:win_space_toggle" ];
        layouts = [
          {
            layout = "us";
          }
          {
            layout = "ara";
          }
        ];
      };
    };
  };
}