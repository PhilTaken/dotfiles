{
  pkgs,
  config,
  ...
} @ inputs: let
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
  command-not-found = pkgs.runCommandLocal "command-not-found.sh" {} ''
    mkdir -p $out/etc/profile.d
    substitute ${./command-not-found.sh}                  \
      $out/etc/profile.d/command-not-found.sh             \
      --replace @nix-locate@ ${nix-locate}/bin/nix-locate \
      --replace @tput@ ${pkgs.ncurses}/bin/tput
  '';
in {
  imports = [
    ./zsh
    ./fish
    ./nushell
  ];

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
      cat = "bat";
      top = "${pkgs.bottom}/bin/btm";
      du = "${pkgs.du-dust}/bin/dust";
      free = "${pkgs.procps}/bin/free -h";
      sudo = "sudo ";
      df = "${pkgs.duf}/bin/duf";
      ezal = "${pkgs.eza}/bin/eza -liaahmF --git --group-directories-first";
      ll = ezal;
      eza = "${pkgs.eza}/bin/eza -Fx --group-directories-first";
      ntop = "sudo ntop -u nobody";
      dmesg = "dmesg -H";
    };

    home.packages = with pkgs; [
      bandwhich
      cmake
      comma
      dig
      dogdns
      dufs
      eza
      fasd
      fd
      file
      gopass
      gping
      hexyl
      hyperfine
      jq
      #lnav
      lolcat
      lsof
      neofetch
      nix-output-monitor
      nmap
      procs
      ranger
      ripgrep
      rsync
      sd
      sshfs
      tealdeer
      tokei
      tree
      unrar
      unzip
      wget
    ];

    programs = {
      bat.enable = true;
      carapace.enable = true;
      htop.enable = true;
      btop = {
        enable = false;
        settings = {
          # general
          background_update = false;
          vim_keys = true;
          force_tty = false;
          show_uptime = true;

          # theme / layout
          color_theme = "TTY";
          theme_background = false;
          truecolor = true;
          rounded_corners = true;
          presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
          temp_scale = "celsius";
          clock_format = "%X /user@/host";

          # procs
          proc_left = true;
          proc_colors = true;
          proc_gradient = true;
          proc_mem_bytes = true;
          proc_cpu_graphs = true;
          proc_per_core = false;
          proc_filter_kernel = false;

          # cpu
          cpu_graph_upper = "total";
          cpu_graph_lower = "user";
          cpu_invert_lower = true;
          show_cpu_freq = true;

          # mem / disks
          mem_graphs = true;
          mem_below_net = false;
          zfs_arc_cached = true;
          show_disks = true;
          zfs_hide_datasets = false;

          # io
          show_io_stat = true;
          io_mode = false;
          io_graph_combined = true;
        };
      };

      rbw = {
        # https://github.com/nix-community/home-manager/issues/4804
        enable = false;
        settings = {
          email = "philipp.herzog@protonmail.com";
          lock_timeout = 300;
        };
      };

      noti.enable = true;

      nix-index = {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "nix-index";
          # Don't provide 'bin/nix-index', since the index is updated automatically
          # and it is easy to forget that. It can always be run manually with
          # 'nix run nixpkgs#nix-index' if necessary.
          paths = [nix-locate command-not-found];
        };
      };

      password-store = {
        enable = true;
        #package = pkgs.pass;
      };

      skim.enable = true;

      # TODO: set up sync
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
        generateCaches = true;
      };

      zoxide.enable = true;

      starship = {
        enable = true;
        settings = {
          add_newline = false;
          character = {
            vicmd_symbol = "λ ·";
            success_symbol = "λ ❱";
            error_symbol = "Ψ ❱";
            #use_symbol_for_status = true;
          };
          package.disabled = true;
          python.symbol = "Py";
          rust.symbol = "R";
          nix_shell = {
            symbol = " ";
            style = "bold blue";
            format = "[$symbol]($style) ";
          };
          git_status = {
            conflicted = "=";
            ahead = "⇡";
            behind = "⇣";
            diverged = "⇕";
            untracked = "?";
            stashed = "$";
            modified = "!";
            staged = "+";
            renamed = "»";
            deleted = "✘";
          };
          jobs.symbol = "+";

          custom.direnv = {
            format = "[\\[direnv\\]]($style) ";
            style = "fg:yellow dimmed";
            when = "env | grep -E '^DIRENV_FILE='";
          };
        };
      };

      yazi = {
        enable = true;
      };

      bacon = {
        enable = true;
        settings = {
        };
      };

      xplr = let
        zoxide = pkgs.fetchFromGitHub {
          owner = "sayanarijit";
          repo = "zoxide.xplr";
          rev = "e50fd35db5c05e750a74c8f54761922464c1ad5f";
          sha256 = "sha256-ZiOupn9Vq/czXI3JHvXUlAvAFdXrwoO3NqjjiCZXRnY=";
        };
        devicons = pkgs.fetchFromGitLab {
          owner = "hartan";
          repo = "web-devicons.xplr";
          rev = "000be1dcc532d90b03cbe549083617376117d9fe";
          sha256 = "sha256-SZo46ayww5Fs5Pf0j4LDjon+5dy+UyzKT1+vdMqrjzo=";
        };
      in {
        enable = true;
        extraConfig = ''
          require('web-devicons.xplr').setup()
          require("zoxide.xplr").setup({
            bin = "zoxide",
            mode = "default",
            key = "Z",
          })
        '';
        plugins = {
          inherit zoxide devicons;
        };
      };
    };
  };
}
