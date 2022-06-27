{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.shells.fish;
in
rec {
  options.phil.shells.fish = {
    enable = mkEnableOption "fish";
  };

  config = mkIf (cfg.enable) {
    programs.fish = {
      enable = true;

      functions = {
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
        su = "command su --shell=${pkgs.fish}/bin/fish $argv";
        enter_ls = ''
          set -l cmd (commandline)
          if test -z "$cmd"
              echo
              ls
          end
          commandline -f execute
        '';
      };

      plugins = [
        {
          name = "magic-enter";
          src = pkgs.fetchFromGitHub {
            owner = "mattmc3";
            repo = "magic-enter.fish";
            rev = "bb82182784c625f0b56f131daa0ec8daac690623";
            sha256 = "sha256-/I75w2NCthTqB/rrQiP2YzzsEU1xgiiupGrlVliWxkY";
          };
        }
      ];

      interactiveShellInit = ''
        set -U fish_greeting

        set -gx ATUIN_NOBIND "true"

        bind -M insert \cr _atuin_search
        bind -M insert -k up _atuin_bind_up
        bind -M insert \eOA _atuin_bind_up
        bind -M insert \e\[A _atuin_bind_up
        bind -M insert \t 'commandline -f complete && _atuin_suppress_tui'
        bind -M insert \e 'commandline -f cancel && _atuin_unsuppress_tui'
        bind -M insert \r 'enter_ls && _atuin_unsuppress_tui'
        bind -M insert \n 'enter_ls && _atuin_unsuppress_tui'
      '';

      shellAliases = rec {
        sudo = "sudo ";
        gre = "${pkgs.ripgrep}/bin/rg";
        df = "df -h";
        free = "${pkgs.procps}/bin/free -h";
        exal = "${pkgs.exa}/bin/exa -liaahmF --git --group-directories-first";
        ll = exal;
        exa = "${pkgs.exa}/bin/exa -Fx --group-directories-first";
        cat = "${pkgs.bat}/bin/bat";
        ntop = "sudo ntop -u nobody";

        top = "${pkgs.bottom}/bin/btm";
        du = "${pkgs.du-dust}/bin/dust";
        dmesg = "dmesg -H";

        # c/c++ dev
        bear = "${pkgs.bear}/bin/bear";
      } // (lib.optionalAttrs inputs.config.wayland.windowManager.sway.enable {
        sockfix = "export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock";
      }) // (lib.optionalAttrs inputs.config.programs.git.enable {
        # git
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
        flkup = "nix flake update --commit-lock-file";
        lg = "${pkgs.lazygit}/bin/lazygit";
      });
    };
  };
}
