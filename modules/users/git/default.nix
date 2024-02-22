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

    signFlavor = mkOption {
      description = "Sign key flavor";
      type = types.enum ["ssh" "openpgp"];
      default = "openpgp";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.git-workspace
      pkgs.git-absorb
    ];

    home.sessionVariables = {
      GIT_WORKSPACE = "${config.home.homeDirectory}/Documents/workspace";
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
        #enable = true;
        background = "dark";
        display = "inline";
      };
      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
          true-color = "always";
        };
      };

      inherit (cfg) userEmail;
      inherit (cfg) userName;

      signing = mkIf (cfg.signKey != null) {
        key = cfg.signKey;
        signByDefault = true;
      };

      includes = [
        {
          condition = "gitdir:${config.home.sessionVariables.GIT_WORKSPACE}";
          contents = {
            user = {
              email = "ph@flyingcircus.io";
              name = "Philipp Herzog";
              signingKey = "CCA0A0D7BD329C162CB381E9C9B5406DBAF07973";
            };
          };
        }
      ];

      aliases = let
        git = "${pkgs.git}/bin/git";
        sort = "${pkgs.coreutils}/bin/sort";
        uniq = "${pkgs.coreutils}/bin/uniq";
      in {
        mergetool = "!nvim -c DiffviewOpen";
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
        merge.conflictstyle = "diff3";
        push.autoSetupRemote = true;

        gpg.format = cfg.signFlavor;
      };
    };
  };
}
