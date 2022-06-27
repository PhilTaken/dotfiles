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
    };

    home.packages = with pkgs; [
      bandwhich
      cmake
      comma
      dig
      exa
      fasd
      fd
      file
      fortune
      gping
      hexyl
      hyperfine
      jq
      lolcat
      lshw
      magic-wormhole
      neofetch
      nmap
      procs
      ripgrep
      rsync
      sd
      sshfs
      tokei
      tree
      unrar
      unzip
      usbutils
      wget
      yt-dlp
    ];

    programs = {
      htop.enable = true;
      bat.enable = true;

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
        package = pkgs.gopass;
      };

      skim.enable = true;

      #watson = {
      #enable = true;
      #};

      atuin.enable = true;

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
            vicmd_symbol = "λ ·";
            success_symbol = "λ ❱";
            error_symbol = "Ψ ❱";
            #use_symbol_for_status = true;
          };
          package.disabled = true;
          python.symbol = "Py";
          rust.symbol = "R";
          nix_shell = {
            symbol = "❄️ ";
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
        };
      };
    };
  };
}
