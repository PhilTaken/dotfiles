{ pkgs, ... }:
{
  programs.git = {
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
      init.defaultBranch = "main";
    };
  };
}
