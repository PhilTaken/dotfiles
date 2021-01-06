# https://rycee.gitlab.io/home-manager/options.html
# https://github.com/nix-community/nix-direnv
# https://github.com/profclems/glab
# TODO: when moving to nixOS swap swaylock with ${pkgs.swaylock}/bin/swaylock
#{ pkgs, rofi_package ? pkgs.rofi, vim_package ? pkgs.nvim, ... }:
{ pkgs, ... }:
let 
  # home_directory = builtins.getEnv "HOME";
  username = "nixos";

  home_directory = "/home/${username}";
  lib = pkgs.stdenv.lib;

  # lock background for shell alias + sway idle
in rec {
  imports = [
    ../modules/mail

    ../modules/git
    ../modules/neovim
    ../modules/ssh

    ../modules/sway
    ../modules/mako
    ../modules/kanshi

    ../modules/zsh_full
  ];

  home = { 
    username = "nixos";
    homeDirectory = "${home_directory}";
    stateVersion = "21.03";
    sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      PAGER = "${pkgs.page}/bin/page";
      MANPAGER = "${pkgs.page}/bin/page -C -e 'au User PageDisconnect sleep 100m|%y p|enew! |bd! #|pu p|set ft=man'";
      _FASD_DATA = "${xdg.dataHome}/fasd/fasd.data";
      _Z_DATA = "${xdg.dataHome}/fasd/z.data";
      CARGO_HOME = "${xdg.dataHome}/cargo";
      RUSTUP_HOME = "${xdg.dataHome}/rustup";
      TEXMFHOME = "${xdg.dataHome}/texmf";
      _ZO_ECHO = 1;

      AWT_TOOLKIT = "MToolkit";
    };
    packages = with pkgs; [
      # core
      cacert
      coreutils
      curl

      niv

      # sway/wayland util
      swaylock
      swayidle
      wl-clipboard
      grim
      sway-contrib.grimshot
      slurp
      imv
      feh
      wev
      wf-recorder
      xorg.xauth
      ydotool
      libnotify
      libappindicator
      glibcLocales

      # git
      git-crypt

      # terminal util
      bandwhich
      bottom
      cmake
      du-dust
      exa
      fasd
      fortune
      hyperfine
      lolcat
      lshw
      neofetch
      page
      pandoc
      playerctl
      powertop
      procs
      ripgrep
      ripgrep-all
      rsync
      sd
      tokei
      topgrade
      universal-ctags
      vpnc
      wmname
      wtf
      youtube-dl

      # other
      discord
      gimp
      #libreoffice-qt
      pamixer
      spotify
      tdesktop
      vlc
      zotero
      cmst
      pavucontrol

      # fonts
      iosevka-bin
      weather-icons
      (nerdfonts.override { fonts = [ "SourceCodePro" ]; })

      # powerline
      powerline-rs
      powerline-fonts

      # extra
      qt5.qtbase

      # TODO
      # rofi-pass-ydotool-git
    ];
  };

  programs = {
    lieer.enable = true;
    notmuch.enable = true;
    afew.enable = true;
    neomutt = {
      enable = true;
    };
    home-manager.enable = true;
    gpg = {
      enable = true;
      settings = {
        default-key = "BDCD0C4E9F252898";
      };
    };

    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
    alacritty = {
      enable = true;
      settings = {
        font.normal.family = "iosevka";
        font.size = 12.0;
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

  programs.zsh.history.path = "${xdg.dataHome}/zsh/histfile";
}
