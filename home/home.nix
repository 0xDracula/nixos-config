{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  flameshot-gui = pkgs.writeShellScriptBin "flameshot-gui" "${pkgs.flameshot}/bin/flameshot gui";
in
{
  imports = [
    ./packages.nix
    ./plasma.nix
    inputs.spicetify-nix.homeManagerModules.default
    inputs.zen-browser.homeModules.twilight
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

  programs.java = {
    enable = true;
    package = pkgs.jdk.override { enableJavaFX = true; };
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
  stylix.targets.spicetify.enable = false;
  stylix.targets.vscode.enable = false;
  stylix.targets.zen-browser.profileNames = [ "dracula" ];
  stylix.targets.nixvim.enable = false;
  #stylix.targets.nixvim.transparentBackground.numberLine = true;
  #stylix.targets.kitty.enable = false;
  programs.vscode.enable = true;
  programs.git = {
    enable = true;
    userName = "0xDracula";
    userEmail = "abdallah.ebrahim.official@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
    };

    package = pkgs.gitFull;
  };
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      alwaysEnableDevTools = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
        oneko
        copyLyrics
        beautifulLyrics
      ];
      enabledSnippets = with spicePkgs.snippets; [
        rotatingCoverart
        pointer
      ];
      theme = spicePkgs.themes.text;
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

  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting ""
      fastfetch
    '';

  };

  programs.kitty = {
    enable = true;
    #settings = {
    #window_padding_width = 15;
    # hide_window_decorations = true;
    #background_blur = 10;
    #};
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/dracula/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "My PipeWire Output"
      }
    '';
  };

  programs.obs-studio = {
    enable = true;

    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # programs.nixvim = {
  #   enable = true;
  #   defaultEditor = true;

  #   extraConfigLua = ''
  #           vim.opt.number = true
  #     	    vim.opt.relativenumber = true
  #     	    vim.opt.wrap = false
  #           vim.opt.expandtab = true
  #     	    vim.opt.tabstop = 2
  #           vim.opt.shiftwidth = 2
  #     	    vim.opt.clipboard = "unnamedplus"
  #     	    vim.opt.scrolloff = 999
  #           vim.opt.virtualedit = "block"
  #           vim.opt.inccommand = "split"
  #           vim.opt.splitright = true
  #           vim.opt.ignorecase = true
  #   '';

  #   plugins.treesitter = {
  #     enable = true;
  #     settings.highlight.enable = true;
  #   };

  #   plugins = {
  #     lsp-format.enable = true;
  #     lsp = {
  #       enable = true;
  #       inlayHints = true;

  #       servers = {
  #         nixd = {
  #           enable = true;
  #           settings = {
  #             formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
  #           };
  #         };
  #       };
  #     };
  #   };
  #   nixpkgs.useGlobalPackages = true;

  #   viAlias = true;
  #   vimAlias = true;
  # };
  programs.ranger.enable = true;
  programs.chromium.enable = true;
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.05";
}
