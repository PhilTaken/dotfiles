{ pkgs, ... }: let 
  username = "nixos";
  home_directory = "/home/${username}";
  lib = pkgs.stdenv.lib;
in rec {
  imports = [
    ../modules/mail

    ../modules/git
    ../modules/neovim
    ../modules/ssh

    ../modules/sway
    ../modules/zsh_full
  ];

  home = { 
    username = "nixos";
    homeDirectory = "${home_directory}";
    stateVersion = "21.03";
    sessionVariables = {
      EDITOR = "${pkgs.neovim-nightly}/bin/nvim";
      PAGER = "${pkgs.page}/bin/page";
      MANPAGER = "${pkgs.page}/bin/page -C -e 'au User PageDisconnect sleep 100m|%y p|enew! |bd! #|pu p|set ft=man'";
      _FASD_DATA = "${xdg.dataHome}/fasd/fasd.data";
      _Z_DATA = "${xdg.dataHome}/fasd/z.data";
      CARGO_HOME = "${xdg.dataHome}/cargo";
      RUSTUP_HOME = "${xdg.dataHome}/rustup";
      TEXMFHOME = "${xdg.dataHome}/texmf";
      _ZO_ECHO = 1;
      XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = 1;
      GTK_USE_PORTAL = 1;
      AWT_TOOLKIT = "MToolkit";
    };
    packages = with pkgs; [
      cacert
      coreutils
      mailcap
      curl
      qt5.qtbase

      # fonts
      iosevka-bin
      weather-icons
      (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
      hicolor-icon-theme

      # terminal util
      cmake
      haxor-news
      playerctl
      tokei
      hyperfine
      powertop
      vpnc
      youtube-dl
      ffmpeg

      # other
      discord
      gimp
      pamixer
      spotify
      tdesktop
      vlc
      zotero
      pavucontrol

      # powerline
      #powerline-rs
      #powerline-fonts
    ];
  };

  programs = {
    home-manager.enable = true;
    gpg = {
      enable = true;
      settings = {
        default-key = "BDCD0C4E9F252898";
      };
    };

    firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        forceWayland = true;
        extraPolicies = {
          ExtensionSettings = {};
        };
      };
    };
    texlive.enable = true;
    zathura.enable = true;
  };

  # services
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [
      "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B"
    ];
  };

  xdg = {
    enable = true;
    configHome = "${home_directory}/.config";
    dataHome = "${home_directory}/.local/share";
    cacheHome = "${home_directory}/.cache";
  };
}
