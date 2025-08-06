{ ... }:
{
  programs.plasma = {
    enable = true;
    shortcuts = {
      "services/org.flameshot.Flameshot.desktop" = {
        "Capture" = "Meta+Shift+S";
      };
    };
    # Commented until I find a fix to only use shortcuts while focus on spotify....
    #hotkeys.commands = {
      #"playerctl-next" = {
         #name = "Playerctl Next";
         #key = "CTRL+Right";
         #command = "playerctl --player=spotify,%any next";
         #logs.enabled = false;
      #};
      #"playerctl-previous" = {
         #name = "Playerctl Previous";
         #key = "CTRL+Left";
         #command = "playerctl --player=spotify,%any previous";
         #logs.enabled = false;
      #};
    #};
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
