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

    phil.twm = {
      enable = true;
      settings = {
        search_paths = ["${config.home.homeDirectory}/Documents/workspace"];
      };
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        user.email = cfg.userEmail;
        user.name = cfg.userName;
        ui.diff-editor = ["nvim" "-c" "DiffEditor $left $right $output"];
        ui.show-cryptographic-signatures = true;
        ui.pager = "${pkgs.delta}/bin/delta";
        ui.diff.format = "git";
        ui.default-command = "log";

        signing = mkIf (cfg.signKey != null) {
          backend = "gpg";
          key = cfg.signKey;
        };

        git.sign-on-push = true;
        git.auto-local-bookmark = true;

        template-aliases = {
          commit_description_verbose = ''
            concat(
              description,
              "\n",
              "JJ: This commit contains the following changes:\n",
              indent("JJ:    ", diff.stat(72)),
              "JJ: ignore-rest\n",
              diff.git(),
            )
          '';
        };

        aliases.dv = ["--config=templates.draft_commit_description=commit_description_verbose" "describe"];
      };
    };

    home.shellAliases = {
      gf = "git fetch -ap --all";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gds = "git diff --staged";
      gr = "git reset";
      grv = "git remote -v";
      gl = "git pull";
      gp = "git push";
      glog = "git log";
      gco = "git checkout";
      gcf = "git checkout $(git branch --all | sed 's/*/ /' | awk '{ print $1; }' | sed 's|remotes/[^/]\\+/||' | sort | uniq | grep -v HEAD | sk)";
      gcm = "git checkout main";
      flkup = "nix flake update --commit-lock-file";
      gwf = "git workspace fetch";
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

      aliases = let
        sort = "${pkgs.uutils-coreutils}/bin/sort";
        uniq = "${pkgs.uutils-coreutils}/bin/uniq";
      in {
        mergetool = "!nvim -c DiffviewOpen";
        tree =
          "log --graph --pretty=format:'%Cred%h%Creset"
          + " —%Cblue%d%Creset %s %Cgreen(%cr)%Creset'"
          + " --abbrev-commit --date=relative --show-notes=*";
        co = "checkout";
        authors = "!git log --pretty=format:%aN | ${sort} | ${uniq} -c | ${sort} -rn";
        b = "branch --color -v";
        ca = "commit --amend";
        changes = "diff --name-status -r";
        clone = "clone --recursive";
        root = "!pwd";
        su = "submodule update --init --recursive";
        undo = "reset --soft HEAD^";
        w = "status -sb";
        wdiff = "diff --color-words";
      };

      extraConfig = {
        init.defaultBranch = "main";
        status.submoduleSummary = true;
        rerere.enabled = true;
        help.autocorrect = 10;
        advice.addEmptyPathspec = false;
        gpg.format = cfg.signFlavor;
        log.date = "iso";

        # un-fsck data corruption
        transfer.fsckobjects = true;
        fetch.fsckobjects = true;
        receive.fsckObjects = true;

        fetch.prune = true;
        fetch.prunetags = true;
        branch.sort = "-committerdate";
        tag.sort = "taggerdate";

        diff = {
          colorMovedWS = "allow-indentation-change";
          colorMoved = "default";
          algorithm = "histogram";
        };

        merge = {
          keepbackup = false;
          conflictstyle = "zdiff3";
          tool = "nvim";
        };

        commit = {
          gpgsign = cfg.signKey != null;
          verbose = true;
          cleanup = "scissors";
        };

        push = {
          default = "current";
          autoSetupRemote = true;
          followtags = true;
        };

        pull.rebase = true;

        rebase = {
          updateRefs = true;
          autosquash = true;
          autostash = true;
        };
      };
    };
  };
}
