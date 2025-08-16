{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./terminals
    ./shells
    ./tmux
    ./zellij
    ./editors
    ./twm

    ./git
    ./ssh
    ./gpg

    ./mail
    ./music
    ./browsers

    ./wms
    ./des

    ./work
    ./leisure
  ];

  options = {
    phil.headless = lib.mkEnableOption "headless user account -> no graphical applications";
  };

  config = {
    stylix.enable = true;
    stylix.polarity = "dark";

    stylix.targets.qt.platform = "qtct";

    xdg.configFile."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
    home.sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";

    nix.registry.nixpkgs.flake = inputs.nixpkgs;

    programs.zk = {
      enable = true;
      settings = {
        notebook.dir = "$HOME/Documents/zk";
        group.journal = {
          paths = [
            "journal/weekly"
            "journal/daily"
          ];
          note.filename = "{{format-date now}}";
        };

        format.markdown = {
          hashtags = true;
          colon-tags = true;
        };

        tool = {
          editor = "nvim";
          shell = "/bin/bash";
          pager = "less -FIRX";
          fzf-preview = "bat -p --color always {-1}";
        };

        filter = {
          recents = "--sort created- --created-after 'last two weeks'";
        };

        alias = {
          edlast = "zk edit --limit 1 --sort modified- $@";
          recent = "zk edit --sort created- --created-after 'last two weeks' --interactive";
          lucky = "zk list --quiet --format full --sort random --limit 1";
          daily = "zk new --no-input journal/daily";
        };

        note = {
          language = "en";
          default-title = "Untitled";
          filename = "{{id}}-{{slug title}}";
          extension = "md";
          id-charset = "alphanum";
          id-length = 4;
          id-case = "lower";
        };

        extra = {
          author = "Philipp";
        };
      };
    };

    home.packages = with pkgs;
      [
        cacert
        uutils-coreutils

        # cachix
        gping
        hyperfine
        tokei
        wget
        fzf
      ]
      ++ (lib.optionals (!config.phil.headless) [
        hicolor-icon-theme
        weather-icons
      ]);
  };
}
