{ pkgs, username, ... }: {
  userDetails = rec {
    name = "${username}";
    sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";
    gpgKey = "BDCD0C4E9F252898";
    pamfile = ../secret/ykchal/maelstroem-14321676;
    font = "SourceCodePro";
    background_image = ./wallpaper/river.jpg;
    extraPackages = with pkgs; [

      # terminal util

      neuron-notes
      newsboat
      youtube-dl

      # other
      #calibre
      anki
      audacity
      chromium
      citra
      digikam
      discord
      element-desktop
      gimp
      libreoffice
      obs-studio
      obsidian
      signal-desktop
      tdesktop
      thunderbird
      #vscodium
      zoom-us

      cachix
      texlive.combined.scheme-medium
      vpnc

      multimc
      openttd

      keepassxc
    ];

    imports = [
      ../../modules/mail

      ../../modules/git
      ../../modules/neovim
      ../../modules/ssh
      ../../modules/firefox

      ../../modules/zsh_full

      ../../modules/music
    ];
  };

  hostDetails = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "docker" "influxdb" "dialout" ];
    shell = pkgs.zsh;
    uid = 1000;
  };
}
