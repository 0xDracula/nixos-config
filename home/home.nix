{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  stylix,
  ...
}: 
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [
    ./packages.nix
    inputs.spicetify-nix.homeManagerModules.default 
    inputs.zen-browser.homeModules.twilight
    inputs.nvf.homeManagerModules.default
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "dracula";
    homeDirectory = "/home/dracula";
  };

  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        offset.y = 5;
      };
      window.padding = {
       x = 20;
       y = 20;
      };
      window.dynamic_padding = true;
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PS1="[\u@\h \w]\$ "
    '';
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "0xDracula";
    userEmail = "abdallah.ebrahim.official@gmail.com";
  };
  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
      beautifulLyrics
      oneko
    ];
    enabledCustomApps = with spicePkgs.apps; [
      newReleases
      ncsVisualizer
    ];
    enabledSnippets = with spicePkgs.snippets; [
      rotatingCoverart
      pointer
    ];
  };
  
  programs.nvf = {
    enable = true;
    
    # Your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    defaultEditor = true;
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.lsp = {
        enable = true;
      };
    };
  };

  programs.zen-browser = {
    enable = true;
    policies = {
       DisableAppUpdate = true;
       DisableTelemetry = true;
       OfferToSaveLogins = true;
       OfferToSaveLoginsDefault = false;
       # find more options here: https://mozilla.github.io/policy-templates/
     };

  };
  stylix.targets.zen-browser.profileNames = [ "dracula" ];
  stylix.targets.vscode.enable = true;
  stylix.targets.qt.platform = "qtct";
  programs.fish.enable = true;
  programs.kitty = {
    enable = true;
    settings = {
      window_padding_width = 15;
    };
  };
  programs.ranger.enable = true;
  programs.chromium.enable = true;
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.05";
}
