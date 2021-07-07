{ pkgs, username, ... }: {
    userDetails = rec {
        name = "${username}";
        sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";
        gpgKey = "BDCD0C4E9F252898";
        font = "SourceCodePro";
        background_image = ./wallpaper/river.jpg;
        extraPackages = with pkgs; [
            #gopass-rofi

            # terminal util
            cmake
            #haxor-news
            playerctl
            tokei
            hyperfine
            youtube-dl
            ffmpeg
            neovim-remote
            jq
            tree
            wget

            # other
            discord
            gimp
            pamixer
            spotify-unwrapped
            tdesktop
            vlc
            obs-studio

            pavucontrol

            signal-desktop
            zoom-us
            element-desktop
            newsboat
            mpv
            #calibre
            thunderbird
            hydroxide

            anki
            texlive.combined.scheme-medium

            cachix
            gping
            vscodium

            vpnc
            libreoffice
            chromium
            multimc

            innernet
            magic-wormhole

            audacity

            digikam

            #fortran-fpm
        ];

        imports = [
            ../modules/mail

            ../modules/git
            ../modules/neovim
            ../modules/ssh
            ../modules/firefox

            ../modules/zsh_full
        ];
    };

    hostDetails = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" "audio" "docker" ];
        shell = pkgs.zsh;
        uid = 1000;
    };
}
