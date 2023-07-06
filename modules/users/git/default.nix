{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.phil.git;
  inherit (lib) mkOption mkIf types;
in {
  options.phil.git = {
    enable = mkOption {
      description = "Enable git";
      type = types.bool;
      default = true;
    };

    userName = mkOption {
      description = "Git username";
      type = types.str;
      default = "Philipp Herzog";
    };

    userEmail = mkOption {
      description = "Git email";
      type = types.str;
      default = "philipp.herzog@protonmail.com";
    };

    signKey = mkOption {
      description = "Sign key";
      type = types.nullOr types.str;
      default = "BDCD0C4E9F252898";
    };
  };

  config = mkIf cfg.enable {
    programs.gitui = {
      enable = true;
      # TODO: keybinds, theme?
    };

    home.packages = [
      pkgs.git-workspace
    ];

    programs.lazygit = {
      enable = true;
      settings = {
        gui.sidePanelWidth = 0.2;
        git = {
          overrideGpg = true;
          paging = {
            colorArg = "always";
            pager = "${pkgs.delta}/bin/delta -s --paging=never";
          };
        };
        #os.editCommand = "${pkgs.neovim-remote}/bin/nvr -cc vsplit --remote-wait +'set bufhidden=wipe'";
      };
    };

    home.shellAliases = {
      gf = "${pkgs.git}/bin/git fetch -ap";
      ga = "${pkgs.git}/bin/git add";
      gc = "${pkgs.git}/bin/git commit";
      gd = "${pkgs.git}/bin/git diff";
      gds = "${pkgs.git}/bin/git diff --staged";
      gr = "${pkgs.git}/bin/git reset";
      grv = "${pkgs.git}/bin/git remote -v";
      gl = "${pkgs.git}/bin/git pull";
      gp = "${pkgs.git}/bin/git push";
      glog = "${pkgs.git}/bin/git log";
      gco = "${pkgs.git}/bin/git checkout";
      gcm = "${pkgs.git}/bin/git checkout main";
      lg = "${pkgs.lazygit}/bin/lazygit";
      flkup = "nix flake update --commit-lock-file";
      gwf = "${pkgs.git}/bin/git workspace fetch";
    };

    programs.git = {
      enable = true;
      ignores = [
        "tags"
        "result"
        ".direnv"
        ".envrc"
      ];
      lfs.enable = true;
      difftastic = {
        enable = true;
        background = "dark";
        display = "inline";
      };
      #delta = {
      #enable = true;
      #options = {
      #line-numbers = true;
      #};
      #};

      inherit (cfg) userEmail;
      inherit (cfg) userName;
      signing = mkIf (cfg.signKey != null) {
        key = cfg.signKey;
        signByDefault = true;
      };

      aliases = let
        git = "${pkgs.git}/bin/git";
        sort = "${pkgs.coreutils}/bin/sort";
        uniq = "${pkgs.coreutils}/bin/uniq";
      in {
        tree =
          "log --graph --pretty=format:'%Cred%h%Creset"
          + " —%Cblue%d%Creset %s %Cgreen(%cr)%Creset'"
          + " --abbrev-commit --date=relative --show-notes=*";
        co = "checkout";
        authors = "!${git} log --pretty=format:%aN | ${sort} | ${uniq} -c | ${sort} -rn";
        b = "branch --color -v";
        ca = "commit --amend";
        changes = "diff --name-status -r";
        clone = "clone --recursive";
        ctags = "!.git/hooks/ctags";
        root = "!pwd";
        spull = "!${git} stash && ${git} pull && ${git} stash pop";
        su = "submodule update --init --recursive";
        undo = "reset --soft HEAD^";
        w = "status -sb";
        wdiff = "diff --color-words";
      };
      extraConfig = {
        pull.rebase = true;
        commit.gpgsign = cfg.signKey != null;
        commit.verbose = true;
        push.default = "tracking";
        status.submoduleSummary = true;
        init.defaultBranch = "main";
        diff.gpg = {
          textconv = "gpg -q --no-tty --decrypt";
          binary = true;
        };
      };
    };
  };
}
