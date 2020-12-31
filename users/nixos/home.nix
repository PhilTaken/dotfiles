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
  lock_bg = ../includes/wallpaper/lock.jpg;
in
  rec {
    home = { 
      username = "nixos";
      homeDirectory = "${home_directory}";
      stateVersion = "21.03";
      sessionPath = [
      # extra dirs for path
      "${home_directory}/.local/bin"
      "${home_directory}/.luarocks/bin"
      "${home_directory}/.config/cargo/bin"
      "${home_directory}/bin"
    ];
    sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      PAGER = "${pkgs.page}/bin/page";
      MANPAGER = "${pkgs.page}/bin/page -C -e 'au User PageDisconnect sleep 100m|%y p|enew! |bd! #|pu p|set ft=man'";

      #GNUPGHOME = "${config.xdg.dataHome}/gnupg";
      _FASD_DATA = "${xdg.dataHome}/fasd/fasd.data";
      _Z_DATA = "${xdg.dataHome}/fasd/z.data";
      CARGO_HOME = "${xdg.dataHome}/cargo";
      RUSTUP_HOME = "${xdg.dataHome}/rustup";
      TEXMFHOME = "${xdg.dataHome}/texmf";
      _ZO_ECHO = 1;

      AWT_TOOLKIT = "MToolkit";
    };

    #fonts.fontconfig.enable = true;
    #targets.genericLinux.enable = true;
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
      cmake
      bandwhich
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
      vpnc
      wmname
      wtf
      youtube-dl
      universal-ctags

      # other
      discord
      gimp
      libreoffice-qt
      pamixer
      spotify
      tdesktop
      vlc
      zotero
      cmst

      # fonts
      iosevka-bin
      weather-icons

      # powerline
      powerline-rs
      powerline-fonts

      # not found
      # rofi-lbonn-wayland
      # rofi-pass-ydotool-git
      # bottom
      # tig
      # workman-git
      # yay
      # bash-language-server
    ];
  };

  programs = {
    home-manager.enable = true;
    gpg.enable = true;
    rofi = {
      enable = true;
      package = pkgs.rofi;
    };

    git = {
      enable = true;
      delta.enable = true;
      lfs.enable = true;
      userEmail = "philipp.herzog@protonmail.com";
      userName = "Philipp Herzog";
      signing.key = "BDCD0C4E9F252898";
      signing.signByDefault = true;
      aliases = {
        tree = "log --graph --pretty=format:'%Cred%h%Creset"
          + " —%Cblue%d%Creset %s %Cgreen(%cr)%Creset'"
          + " --abbrev-commit --date=relative --show-notes=*";
        co = "checkout";
        authors = "!${pkgs.git}/bin/git log --pretty=format:%aN"
          + " | ${pkgs.coreutils}/bin/sort" + " | ${pkgs.coreutils}/bin/uniq -c"
          + " | ${pkgs.coreutils}/bin/sort -rn";
        b = "branch --color -v";
        ca = "commit --amend";
        changes = "diff --name-status -r";
        clone = "clone --recursive";
        ctags = "!.git/hooks/ctags";
        root = "!pwd";
        spull = "!${pkgs.git}/bin/git stash" + " && ${pkgs.git}/bin/git pull"
          + " && ${pkgs.git}/bin/git stash pop";
        su = "submodule update --init --recursive";
        undo = "reset --soft HEAD^";
        w = "status -sb";
        wdiff = "diff --color-words";
      };
      extraConfig = {
        pull.rebase = false;
        commit.gpgsign = true;
        commit.verbose = true;
        push.default = "tracking";
        status.submoduleSummary = true;
      };
    };
    bat.enable = true;
    direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
      enableZshIntegration = true;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
    htop.enable = true;
    mako = {
      enable = true;
      maxVisible = 5;
      defaultTimeout = 5000;
      font = "iosevka";
      backgroundColor = "#FFFFFF";
      textColor = "#000000";
      borderColor = "#000000";
      borderSize = 2;
      borderRadius = 4;
    };
    man = {
      enable = true;
      generateCaches = false;
    };
    neovim = let 
      neovim-config-file = ../includes/neovim/init.vim;
    in {
      # TODO upgrade to nvim 0.5-nightly
      enable = true;
      package = pkgs.neovim;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      plugins = with pkgs.vimPlugins; [
        vim-fugitive
        vim-gitgutter
        vim-rooter
        vim-startify
        colorizer
        vim-surround
        vim-speeddating
        vim-snippets
        targets-vim
        echodoc-vim
        nerdcommenter
        auto-pairs
        vim-tmux-navigator
        vim-airline
        vim-airline-themes
        vim-pandoc
        vim-pandoc-syntax
        vim-nix
        ayu-vim
        ultisnips

        coc-nvim
        coc-vimtex
        coc-git
        coc-json
        coc-css
      ];
      extraConfig = builtins.readFile neovim-config-file;
      #extraPython3Packages =  (ps: with ps; [ pynvim ]);
    };
    password-store = {
      enable = true;
      package = pkgs.gopass;
    };
    skim = {
      enable = true;
      enableZshIntegration = true;
    };
    ssh = {
      enable = true;
      extraConfig = ''
        IdentityFile ~/.ssh/id_files/id_rsa_work
        IdentityFile ~/.ssh/id_files/id_rsa_private
        IdentityFile ~/.ssh/id_files/id_rsa_other
        IdentityFile ~/.ssh/id_rsa
      '';
      matchBlocks = {
        "jureca" = {
          hostname = "jureca.fz-juelich.de";
          user = "herzog1";
          forwardAgent = true;
          forwardX11 = true;
        };
        "judac" = {
          hostname = "judac.fz-juelich.de";
          user = "herzog1";
          forwardAgent = true;
          forwardX11 = true;
        };
        "work-pc" = {
          hostname = "iek8680.iek.kfa-juelich.de";
          user = "p.herzog";
          forwardAgent = true;
          forwardX11 = true;
        };
        "vulkan" = {
          hostname = "iek8691.iek.kfa-juelich.de";
          user = "p.herzog";
          forwardX11 = true;
          forwardAgent = true;
        };
        "mcserver" = {
          hostname = "192.168.192.42";
          user = "non-admin";
        };
        "router" = {
          hostname = "router.lan";
          user = "root";
        };
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        character = {
          vicmd_symbol = "λ ·";
          success_symbol = "λ ❱";
          error_symbol = "Ψ ❱";
          use_symbol_for_status = true;
        };
        package.disabled = true;
        python.symbol = "Py ";
        rust.symbol = "R ";
        nix-shell = {
          ignore_msg = "";
          pure_msg = "";
          symbol = "nix-shell";
          format = "";
        };
        git_status = {
          ahead = "⇡ ";
          behind = "⇣ ";
        };
        jobs.symbol = "+";
      };
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
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    tmux = let 
      airline_conf = ../includes/shell/tmux_airline.conf;
    in {
      enable = true;
      baseIndex = 1;
      escapeTime = 1;
      keyMode = "vi";
      secureSocket = true;
      shortcut = "a";
      terminal = "screen-256color";
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '30'
          '';
        }
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-dir '${xdg.dataHome}/tmux-resurrect/data'
          '';
        }
      ];
      extraConfig = ''
        source ${airline_conf}

        set -g mouse on
        setw -g monitor-activity on
        set -g visual-activity on

        bind Escape copy-mode
        unbind p
        bind p paste-buffer
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection
        bind-key -T copy-mode-vi 'Space' send -X halfpage-down
        bind-key -T copy-mode-vi 'Bspace' send -X halfpage-up

        bind | split-window -h -c '#{pane_current_path}'
        bind - split-window -v -c '#{pane_current_path}'
        unbind '"'
        unbind '%'
        unbind C-a

        bind y select-pane -L
        bind n select-pane -D
        bind e select-pane -U
        bind o select-pane -R

        bind -r C-y select-window -t :-
        bind -r C-o select-window -t :+

        bind -r Y resize-pane -L 5
        bind -r N resize-pane -D 5
        bind -r E resize-pane -U 5
        bind -r O resize-pane -R 5
      '';
    };
    waybar = let 
      css_file = ../includes/waybar/style.css;
      weather_exec = ../includes/waybar/openweathe-rs;
    in
      {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 15;
          modules-left = ["idle_inhibitor" "sway/workspaces" "sway/mode"];
          modules-center = ["custom/weather"];
          modules-right = ["pulseaudio" "battery" "memory" "network" "custom/vpn" "clock" "tray"];
          modules = {
            "sway/workspaces" = {
              icon-size = 20;
              disable-scroll = true;
              all-outputs = false;
              format = "{name}";
            };
            "sway/mode".format = "<span style=\"italic\">{}</span>";
            "idle_inhibitor" = {
              format = "{icon}";
              format-icons.activated = "";
              format-icons.deactivated = "";
            };
            "tray".spacing = 10;
            "clock" = {
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              format-alt = "{:%Y-%m-%d}";
            };
            "memory".format = "{}% ";
            "battery" = {
              states.warning = 30;
              states.critical = 15;
              format = "{capacity}% {icon}";
              format-icons = ["" "" "" "" ""];
            };
            "network" = {
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{ifname} ";
              format-disconnected = "Disconnected ⚠";
              on-click = "cmst";
              tooltip-format = "{ipaddr}/{cidr}, {bandwidthUpBits} up, {bandwidthDownBits} down";
            };
            "pulseaudio" = {
              scroll-step = 5;
              format = "{volume}% {icon}";
              format-muted = "{icon}";
              format-icons = {
                headphones = "";
                default = ["" ""];
              };
              on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
              on-click-right = "pavucontrol";
            };
            "custom/vpn" = {
              interval = 1;
              return-type = "json";
              exec = pkgs.writeShellScript "vpn"  ''
                wg >/dev/null 2>&1
                connected=$?
                
                if [ $connected -eq 1 ]; then
                  icon=""
                  class="connected"
                else
                  icon=""
                  class="disconnected"
                fi

                echo -e "{\"text\":\""$icon"\", \"tooltip\":\"Wireguard VPN ("$class")\", \"class\":\""$class"\"}"
              '';
              escape = true;
            };
            "custom/weather" = {
              interval = 900;
              exec = "${weather_exec}";
            };
          };
        }
      ];
      style = builtins.readFile css_file;
      systemd.enable = true;
    };
    zsh = let 
      magic_enter_prompt = ../includes/shell/magic_enter.zsh;
    in {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      autocd = true;
      defaultKeymap = "viins";
      dotDir = ".config/zsh";
      history = {
        ignoreDups = true;
        ignoreSpace = true;
        path = "${xdg.dataHome}/zsh/histfile";
        share = true;
      };
      initExtraBeforeCompInit = ''
        setopt prompt_subst
        setopt prompt_sp
        setopt always_to_end
        setopt complete_in_word
        setopt hist_verify

        setopt extended_glob
        setopt nomatch

        setopt complete_aliases
        setopt mark_dirs
        setopt bang_hist
        setopt extended_history

        setopt interactive_comments
        setopt auto_continue
        setopt pipefail

        unsetopt beep notify clobber
      '';
      initExtra = ''
        autoload -Uz zmv
        autoload -Uz zed

        zle_highlight=(iserach:underline)

        zstyle ':completion:*' special-dirs true
        zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,comm'

        zstyle ':completion:*' completer _complete _match _approximate
        zstyle ':completion:*:match:*' original only
        zstyle ':completion:*:approximate:*' max-errors 10 numeric

        WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

        eval "$(fasd --init auto)"
        unalias z

        source ${magic_enter_prompt}

        if [[ $DISPLAY ]]; then
          [[ $- != *i* ]] && return
          if [[ -z "$TMUX" ]]; then
            ID="$(${pkgs.tmux}/bin/tmux ls | grep -vm1 attached | cut -d: -f1)"
            if [[ -z "$ID" ]]; then
              ${pkgs.tmux}/bin/tmux new-session
            else
              ${pkgs.tmux}/bin/tmux attach-session -t "$ID"
            fi
          fi
        fi
      '';
      shellAliases = {
        sudo = "sudo ";
        #cp = "rsync";
        gre = "rg";
        df = "df -h";
        free = "free -h";
        exal = "${pkgs.exa}/bin/exa -liaahmF --git --group-directories-first";
        exa = "${pkgs.exa}/bin/exa -Fx --group-directories-first";
        ll = "exal";
        cat = "bat";
        ntop = "sudo ntop -u nobody";
        open = "xdg-open";
        pass = "gopass";
        #sway = "XDG_SESSION_TYPE=wayland nixGLIntel exec sway";
        yta = "youtube-dl -x --audio-format flac";
        vo = "f -fe zathura";

        sockfix = "export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock";

        # TODO change to vim/whatever vim I installed
        v = "f -fte nim";
        vimup = "nim +PlugUpdate +qall";

        lock = "swaylock -i ${lock_bg}";
        ga = "git add";
        gc="git commit";
        gd="git diff";
        gr="git remote";
        gs="git status";
        gl="git pull";
        gp="git push";
        glog="git log";
        gpsup="git push --set-upstream origin master";
        gco="git checkout";
        gcm="git checkout master";
        du="dust";
      };
    };
  };

  # sway window manager
  wayland.windowManager.sway = let
    std_opacity = "0.96";
    lock = "swaylock -c 000000";
    # TODO: package as derivation, as well as the other bin/ scripts
    screen_recorder = "record_screen.sh";
  in {
    enable = true;
    #package = pkgs.sway-unwrapped;
    #wrapperFeatures.gtk = true;
    config = {
      up = "e";
      down = "n";
      left = "y";
      right = "o";
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "rofi -show run";
      floating.border = 0;
      focus.followMouse = "always";
      bindkeysToCode = false;
      bars = [];
      # TODO: colors
      gaps = {
        inner = 15;
        outer = 0;
        smartBorders = "on";
      };
      input = {
        "*" = {
          xkb_layout = "us(intl)";
          xkb_options = "caps:escape";
        };
        "1:1:AT_Translated_Set_2_keyboard" = {
          xkb_layout = "us(workman-intl),us(intl)";
          xkb_options = "caps:escape,grp:shifts_toggle";
        };
        "1241:36:HOLDCHIP_USB_Gaming_Keyboard" = {
          xkb_layout = "us(workman-intl)";
          xkb_options = "caps:escape,altwin:swap_alt_win";
        };
        "4152:5929:SteelSeries_SteelSeries_Rival_110_Gaming_Mouse" = {
          accel_profile = "flat";
        };
      };
      keybindings = let
        swayconf = wayland.windowManager.sway.config;
        left = swayconf.left;
        right = swayconf.right;
        up = swayconf.up;
        down = swayconf.down;
        term = swayconf.terminal;
        mod = swayconf.modifier;
        menu = swayconf.menu;
      in {
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+u" = "exit";
        "${mod}+Return" = "exec ${term}";
        "${mod}+q" = "exec ${screen_recorder}";
        "${mod}+d" = "kill";
        "${mod}+Space" = "exec ${menu}";
        "${mod}+l" = "exec ${pkgs.swaylock}/bin/swaylock -i ${lock_bg} &";
        "${mod}+p" = "exec rofi-pass";
        "${mod}+u" = "exec rofi -terminal ${term} -show ssh";
        "${mod}+s" = "layout tabbed";
        "${mod}+j" = "layout toggle split";
        "${mod}+f" = "fullscreen";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+${left}" = "focus left";
        "${mod}+${right}" = "focus right";
        "${mod}+${up}" = "focus up";
        "${mod}+${down}" = "focus down";
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${right}" = "move right";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Ctrl+${left}" = "move workspace output left";
        "${mod}+Ctrl+${right}" = "move workspace output right";
        "${mod}+Ctrl+${up}" = "move workspace output up";
        "${mod}+Ctrl+${down}" = "move workspace output down";
        "${mod}+1" = "workspace 1";
        "${mod}+2" = "workspace 2";
        "${mod}+3" = "workspace 3";
        "${mod}+4" = "workspace 4";
        "${mod}+5" = "workspace 5";
        "${mod}+6" = "workspace 6";
        "${mod}+7" = "workspace 7";
        "${mod}+8" = "workspace 8";
        "${mod}+9" = "workspace 9";
        "${mod}+0" = "workspace 10";
        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+2" = "move container to workspace 2";
        "${mod}+Shift+3" = "move container to workspace 3";
        "${mod}+Shift+4" = "move container to workspace 4";
        "${mod}+Shift+5" = "move container to workspace 5";
        "${mod}+Shift+6" = "move container to workspace 6";
        "${mod}+Shift+7" = "move container to workspace 7";
        "${mod}+Shift+8" = "move container to workspace 8";
        "${mod}+Shift+9" = "move container to workspace 9";
        "${mod}+Shift+0" = "move container to workspace 10";
        "XF86MonBrightnessUp" = "exec light -T 1.4 && lightctl";
        "XF86MonBrightnessDown" = "exec light -T 0.72 && lightctl";
        "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
        "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ud 2 && volumectl";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ui 2 && volumectl";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      };
      assigns = {
        "2" = [{app_id = "firefox";}];
        "3" = [{class = "discord";}];
        "4" = [{class = "Spotify";}];
      };
      floating.criteria = [ { app_id = "avizo-service"; } ];
      startup = [
        { command = "avizo-service"; }
        { command = "${pkgs.mako}/bin/mako"; }
        { command = "${pkgs.ydotool}/bin/ydotoold"; }
        { command = "systemctl --user restart kanshi"; always = true; }
        { command = "systemctl --user restart waybar"; always = true; }
        #{ command = "systemctl --user restart waybar"; always = true; }
        # TODO check this
        #{
        #  command = ''
        #    ${pkgs.swayidle}/bin/swayidle -w \
        #      timeout 120 '${pkgs.coreutils}/bin/echo `xbacklight -get` > /tmp/bn && xbacklight -set 10 -fps 20' \
        #        resume 'xbacklight -set `${pkgs.coreutils}/bin/cat /tmp/bn` -fps 20' \
        #      timeout 240 'swaylock -i ${lock_bg} -f -c 000000 && ${pkgs.sway-unwrapped}/bin/swaymsg  "output * dpms off"' \
        #        resume '${pkgs.sway-unwrapped}/bin/swaymsg "output * dpms on"' \
        #      before-sleep 'swaylock -i ${lock_bg} -f -c 000000'
        #  '';
        #}
      ];
      window.commands = [
        { 
          command = "inhibit_idle fullscreen";
          criteria = { app_id = "firefox"; };
        }
        {
          command = "opacity ${std_opacity}";
          criteria = { app_id = ".*"; };
        }
        {
          command = "opacity 1";
          criteria = { app_id = "firefox"; };
        }
        {
          command = "opacity 1";
          criteria = { app_id = "org.pwmt.zathura"; };
        }
      ];
      output = { "*" = { bg = "${lock_bg} fill"; }; };
    };
  };

  # services
  services.gpg-agent.enable = true;
  services.kanshi = {
    enable = true;
    profiles = {
      "dockstation" = {
        exec = "notify-send 'Kanshi switched to dockstation profile'";
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL U2415 XKV0P05J16ZS";
            mode = "1920x1200";
            position = "0,1200";
          }
          {
            criteria = "Dell Inc. DELL U2415 XKV0P05J16YS";
            mode = "1920x1200";
            transform = "270";
            position = "1920,0";
          }
        ];
      };
      "default" = {
        exec = "notify-send 'Kanshi switched to default profile'";
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "1920x1080";
            position = "0,0";
          }
        ];
      };
      "at-home-1" = {
        exec = "notfiy-send 'Welcome home!'";
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "Unknown 2460G4 0x0000C93A";
            mode = "1920x1080@119.98Hz";
            position = "1920,0";
          }
        ];
      };
      "at-home-2" = {
        exec = "notfiy-send 'Welcome home!'";
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "Unknown TERRA 2455W 0x00000101";
            mode = "1920x1080";
            position = "1920,0";
          }
        ];
      };
    };
  };

  xdg = {
    enable = true;

    configHome = "${home_directory}/.config";
    dataHome = "${home_directory}/.local/share";
    cacheHome = "${home_directory}/.cache";
  };
}
