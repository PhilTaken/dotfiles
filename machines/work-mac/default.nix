{
  pkgs,
  npins,
  config,
  ...
}: {
  imports = [
    ./philippherzog.nix
  ];

  stylix = {
    image = ../../images/vortex.png;
    base16Scheme = "${npins.base16}/base16/mocha.yaml";

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        #package = pkgs.dejavu_fonts;
        #name = "DejaVu Sans Mono";
        package = pkgs.iosevka-comfy.comfy-duo;
        name = "Iosevka Comfy";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  # Auto upgrade nix package and the daemon service.
  nix.extraOptions = ''
    build-users-group = nixbld
    bash-prompt-prefix = (nix:$name)\040
    extra-nix-path = nixpkgs=flake:nixpkgs
    experimental-features = flakes nix-command
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # fix for previous nix install
  ids.gids.nixbld = 350;

  programs.fish.enable = true;
  programs.zsh.enable = true;

  environment.shells = [
    "/run/current-system/sw/bin/nu"
    "/run/current-system/sw/bin/fish"
    pkgs.zsh
  ];

  environment.systemPackages = [pkgs.openssh];

  # services.karabiner-elements.enable = true;
  services.tailscale.enable = true;
  services.tailscale.overrideLocalDns = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    casks = [
      "1password"
      "1password-cli"
      "hammerspoon"
      "raycast"
      "jitsi-meet"
      "spotify"
      "karabiner-elements"
      "telegram"
      {
        name = "zen-browser";
        greedy = true;
      }
      "element"
      "dehesselle-meld"
      "ghostty"
      "rectangle"
      "nextcloud"
    ];
  };

  environment.shellAliases = {
    "meld" = "/Applications/Meld.app/Contents/MacOS/Meld";
  };

  fonts.packages = [
    pkgs.jetbrains-mono
    pkgs.aporetic
    pkgs.ibm-plex
    pkgs.iosevka-comfy.comfy
    pkgs.nerd-fonts.sauce-code-pro
    pkgs.nerd-fonts.iosevka
  ];

  users.users.philippherzog = {
    name = "philippherzog";
    description = "Philipp Herzog";
    home = "/Users/philippherzog";
    shell = pkgs.fish;
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  system.defaults = {
    LaunchServices = {
      # Disable quarantine for downloaded apps
      LSQuarantine = false;
    };
    ActivityMonitor = {
      # Sort by CPU usage
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
    trackpad = {
      # Enable trackpad tap to click
      Clicking = true;

      # Enable 3-finger drag
      TrackpadThreeFingerDrag = true;
    };
    finder = {
      # Allow quitting via ⌘Q
      QuitMenuItem = true;

      # Disable warning when changing a file extension
      FXEnableExtensionChangeWarning = false;

      # Show all files and their extensions
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;

      # Show path bar, and layout as multi-column
      ShowPathbar = true;
      FXPreferredViewStyle = "clmv";

      # Search in current folder by default
      FXDefaultSearchScope = "SCcf";
    };
    NSGlobalDomain = {
      # Auto hide the menubar
      _HIHideMenuBar = true;

      # Enable full keyboard access for all controls
      AppleKeyboardUIMode = 3;

      # "Natural" scrolling
      "com.apple.swipescrolldirection" = true;

      # Disable smart dash/period/quote substitutions
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;

      # Disable automatic capitalization
      NSAutomaticCapitalizationEnabled = false;

      # Using expanded "save panel" by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Save to disk (not to iCloud) by default
      NSDocumentSaveNewDocumentsToCloud = true;
    };
    CustomUserPreferences = {
      "com.knollsoft.Rectangle" = {
        screenEdgeGapTop = 32;
        screenEdgeGapTopNotch = 0;
        # screenEdgeGapsOnMainScreenOnly = true;
      };
      "org.hammerspoon.Hammerspoon" = {
        MJConfigFile = "~/.config/hammerspoon/init.lua";
      };
      "com.apple.finder" = {
        # Keep the desktop clean
        ShowHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;

        # Show directories first
        _FXSortFoldersFirst = true; # TODO: https://github.com/LnL7/nix-darwin/pull/594

        # New window use the $HOME path
        NewWindowTarget = "PfHm";
        NewWindowTargetPath = "file://$HOME/";

        # Allow text selection in Quick Look
        QLEnableTextSelection = true;
      };
      "com.apple.CrashReporter" = {
        # Disable crash reporter
        DialogType = "none";
      };
      "com.apple.AdLib" = {
        # Disable personalized advertising
        forceLimitAdTracking = true;
        allowApplePersonalizedAdvertising = false;
        allowIdentifierForAdvertising = false;
      };
    };

    dock.mru-spaces = false;
    dock.orientation = "left";
    dock.autohide = true;

    screencapture.location = "~/Pictures/screenshots";
  };

  system.activationScripts.setting.text = ''
    # Allow opening apps from any source
    sudo spctl --master-disable
  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
