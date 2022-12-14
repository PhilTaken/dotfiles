{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.shells;

  # Automatically download the latest index from Mic92's nix-index-database.
  nix-locate = pkgs.writeShellScriptBin "nix-locate" ''
    set -euo pipefail
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    # Check for updates at most once a day
    if [ ! -f last-check ] || [ $(find last-check -mtime +1) ]; then
      filename="index-x86_64-$(uname | tr A-Z a-z)"
      # Delete partial downloads
      [ -f files ] || rm -f $filename
      wget -q -N --show-progress \
        https://github.com/Mic92/nix-index-database/releases/latest/download/$filename
      ln -f $filename files
      touch last-check
    fi
    exec ${pkgs.nix-index}/bin/nix-locate "$@"
  '';

  # Modified version of command-not-found.sh that uses our wrapped version of
  # nix-locate, makes the output a bit less noisy, and adds color!
  command-not-found = pkgs.runCommandLocal "command-not-found.sh" { } ''
    mkdir -p $out/etc/profile.d
    substitute ${./command-not-found.sh}                  \
      $out/etc/profile.d/command-not-found.sh             \
      --replace @nix-locate@ ${nix-locate}/bin/nix-locate \
      --replace @tput@ ${pkgs.ncurses}/bin/tput
  '';

in
{
  imports = [
    ./zsh
    ./fish
  ];

  options.phil.shells = { };

  config = {
    home.sessionVariables = {
      _FASD_DATA = "${inputs.config.xdg.dataHome}/fasd/fasd.data";
      _Z_DATA = "${inputs.config.xdg.dataHome}/fasd/z.data";
      _ZO_ECHO = 1;
      # silence direnv warnings for "long running commands"
      DIRENV_WARN_TIMEOUT = "24h";
      # silence direnv and provide information via starship
      DIRENV_LOG_FORMAT = "";
    };

    home.shellAliases = rec {
      zj = "${pkgs.zellij}/bin/zellij";
      gre = "${pkgs.ripgrep}/bin/rg";
      cat = "${pkgs.bat}/bin/bat";
      top = "${pkgs.bottom}/bin/btm";
      du = "${pkgs.du-dust}/bin/dust";
      free = "${pkgs.procps}/bin/free -h";
      sudo = "sudo ";
      df = "df -h";
      exal = "${pkgs.exa}/bin/exa -liaahmF --git --group-directories-first";
      ll = exal;
      exa = "${pkgs.exa}/bin/exa -Fx --group-directories-first";
      ntop = "sudo ntop -u nobody";
      dmesg = "dmesg -H";
    } // (lib.optionalAttrs inputs.config.wayland.windowManager.sway.enable {
      sockfix = "export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock";
    }) // (lib.optionalAttrs inputs.config.programs.git.enable {
      ga = "${pkgs.git}/bin/git add";
      gc = "${pkgs.git}/bin/git commit";
      gd = "${pkgs.git}/bin/git diff";
      gr = "${pkgs.git}/bin/git reset";
      grv = "${pkgs.git}/bin/git remote -v";
      gl = "${pkgs.git}/bin/git pull";
      gp = "${pkgs.git}/bin/git push";
      glog = "${pkgs.git}/bin/git log";
      gco = "${pkgs.git}/bin/git checkout";
      gcm = "${pkgs.git}/bin/git checkout main";
      lg = "${pkgs.lazygit}/bin/lazygit";
      flkup = "nix flake update --commit-lock-file";
    });

    home.packages = with pkgs; [
      cmake
      comma
      dig
      dogdns
      exa
      fasd
      fd
      file
      fortune
      gopass
      gping
      hexyl
      hyperfine
      lolcat
      lshw
      lsof
      magic-wormhole
      neofetch
      nmap
      procs
      psmisc
      ranger
      ripgrep
      rsync
      sshfs
      tokei
      tree
      unrar
      unzip
      usbutils
      wget
      yt-dlp
      glances

      tealdeer
      jq
      bandwhich
      sd
      pup
      joshuto
    ];

    programs = {
      htop.enable = true;
      bat.enable = true;
      noti.enable = true;

      nix-index = {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "nix-index";
          # Don't provide 'bin/nix-index', since the index is updated automatically
          # and it is easy to forget that. It can always be run manually with
          # 'nix run nixpkgs#nix-index' if necessary.
          paths = [ nix-locate command-not-found ];
        };
      };

      password-store = {
        enable = true;
        #package = pkgs.pass;
      };

      skim.enable = true;

      #watson = {
      #enable = true;
      #};

      atuin = {
        enable = true;
        settings = {
          search_mode = "fuzzy";
          update_check = false;
          style = "compact";
        };
      };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      man = {
        enable = true;
        generateCaches = false;
      };

      zoxide.enable = true;

      starship = {
        enable = true;
        settings = {
          add_newline = false;
          character = {
            vicmd_symbol = "?? ??";
            success_symbol = "?? ???";
            error_symbol = "?? ???";
            #use_symbol_for_status = true;
          };
          package.disabled = true;
          python.symbol = "Py";
          rust.symbol = "R";
          nix_shell = {
            symbol = "??? ";
            style = "bold blue";
            format = "[$symbol]($style) ";
          };
          git_status = {
            conflicted = "=";
            ahead = "???";
            behind = "???";
            diverged = "???";
            untracked = "?";
            stashed = "$";
            modified = "!";
            staged = "+";
            renamed = "??";
            deleted = "???";
          };
          jobs.symbol = "+";

          custom.direnv = {
            format = "[\\[direnv\\]]($style) ";
            style = "fg:yellow dimmed";
            when = "env | grep -E '^DIRENV_FILE='";
          };
        };
      };
    };
  };
}
