{ pkgs, ... }: {
    userDetails = rec {
        name = "nixos";
        sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";
        gpgKey = "BDCD0C4E9F252898";
        font = "SourceCodePro";
        background_image = "mountain.jpg";
        extraPackages = with pkgs; [
            gopass-rofi

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
            neovim-remote
            jq
            tree

            # other
            discord
            gimp
            pamixer
            spotify
            tdesktop
            vlc
            pavucontrol

            element-desktop
            newsboat
            mpv
            calibre
            thunderbird
            hydroxide
            anki

            pulseeffects-pw
            texlive.combined.scheme-medium

            cachix
        ];

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
