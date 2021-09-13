{ pkgs, ... }: {
    userDetails = rec {
        name = "nixos";
        sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";
        gpgKey = "BDCD0C4E9F252898";
        pamfile = ../secret/ykchal/nixos-14321676;
        font = "SourceCodePro";
        background_image = ./wallpaper/city-night.png;
        extraPackages = with pkgs; [
            #gopass-rofi

            # terminal util
            cmake
            #haxor-news
            tokei
            hyperfine
            youtube-dl

            jq
            tree
            wget

            # other
            discord
            gimp
            tdesktop

            element-desktop
            newsboat
            #calibre
            thunderbird
            hydroxide

            #pulseeffects-pw

            anki
            texlive.combined.scheme-medium

            cachix

            magic-wormhole
            gping

            goneovim

            tightvnc
            obsidian
        ];

        imports = [
            ../modules/mail

            ../modules/git
            ../modules/neovim
            ../modules/ssh
            ../modules/firefox

            ../modules/zsh_full

            ../modules/music
        ];
    };

    hostDetails = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" "audio" "docker" "dialout" ];
        shell = pkgs.zsh;
        uid = 1001;
    };
}
