{ pkgs, ... }: {
  userDetails = {
    name = "nixos";
    sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";
    gpgKey = "BDCD0C4E9F252898";
    font = "SourceCodePro";
    extraPackages = with pkgs; [
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
      element-desktop
    ];

    sessionVars = {
      EDITOR = "${pkgs.neovim-nightly}/bin/nvim";
      PAGER = "${pkgs.page}/bin/page";
      MANPAGER = "${pkgs.page}/bin/page -C -e 'au User PageDisconnect sleep 100m|%y p|enew! |bd! #|pu p|set ft=man'";
      _FASD_DATA = "$XDG_DATA_HOME/fasd/fasd.data";
      _Z_DATA = "$XDG_DATA_HOME/fasd/z.data";
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
      TEXMFHOME = "$XDG_DATA_HOME/texmf";
      _ZO_ECHO = 1;
      XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = 1;
      GTK_USE_PORTAL = 1;
      AWT_TOOLKIT = "MToolkit";
    };
    imports = [
      ../modules/mail

      ../modules/git
      ../modules/neovim
      ../modules/ssh

      ../modules/sway
      ../modules/zsh_full
    ];
  };

  hostDetails = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "docker" ];
    shell = pkgs.zsh;
  };
}
