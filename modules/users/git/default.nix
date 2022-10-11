{ pkgs
, config
, lib
, ...
}:
with lib;

let cfg = config.phil.git;
in
{
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
    programs.lazygit = {
      enable = true;
      settings = {
        gui.sidePanelWidth = 0.2;
        git.paging = {
          colorArg = "always";
          pager = "${pkgs.delta}/bin/delta -s --paging=never";
        };
        #os.editCommand = "${pkgs.neovim-remote}/bin/nvr -cc vsplit --remote-wait +'set bufhidden=wipe'";
      };
    };


    programs.git = {
      enable = true;
      ignores = [
        "tags"
        "result"
        ".direnv"
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

      aliases =
        let
          git = "${pkgs.git}/bin/git";
          sort = "${pkgs.coreutils}/bin/sort";
          uniq = "${pkgs.coreutils}/bin/uniq";
        in
        {
          tree = "log --graph --pretty=format:'%Cred%h%Creset"
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
      };
    };
  };
}
