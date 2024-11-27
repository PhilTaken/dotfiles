{
  pkgs,
  npins,
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
  services.nix-daemon.enable = true;
  nix.extraOptions = ''
    build-users-group = nixbld
    bash-prompt-prefix = (nix:$name)\040
    extra-nix-path = nixpkgs=flake:nixpkgs
    experimental-features = flakes nix-command
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.fish.enable = true;
  programs.zsh.enable = true;

  environment.shells = [
    "/run/current-system/sw/bin/nu"
    "/run/current-system/sw/bin/fish"
    pkgs.zsh
  ];

  environment.systemPackages = [pkgs.openssh];

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "hammerspoon"
      "karabiner-elements"
      "raycast"
      "jitsi"
      "spotify"
      "logseq"
      "zen-browser"
      "element"
    ];

    onActivation.cleanup = "zap";
  };

  users.users.philippherzog = {
    name = "philippherzog";
    description = "Philipp Herzog";
    home = "/Users/philippherzog";
    shell = pkgs.fish;
  };

  security.pam.enableSudoTouchIdAuth = true;

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

      # Disable "Natural" scrolling
      "com.apple.swipescrolldirection" = false;

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
    CustomSystemPreferences = {
      "com.knollsoft.Rectangle" = {
        screenEdgeGapTopNotch = 0;
        screenEdgeGapTop = 32;
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
