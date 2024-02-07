{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.phil.zellij;
  settings = import ./config.nix {inherit pkgs cfg;};
  inherit (lib) mkOption mkIf types;
  #barplugin = "zellij:compact-bar";
in {
  options.phil.zellij = {
    enable = mkOption {
      description = "zellij";
      type = lib.types.bool;
      default = config.phil.terminals.multiplexer == "zellij";
    };

    defaultShell = mkOption {
      type = types.nullOr (types.enum ["fish" "zsh"]);
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.zellij
    ];

    xdg.configFile."zellij/config.kdl" = {
      source = settings.configFile;
    };

    xdg.configFile."zellij/layouts/default.kdl".text = ''
      layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                      format_left  "{mode} #[fg=#89B4FA,bold]{session} {tabs}"
                      format_right "{command_git_branch} {datetime}"
                      format_space ""

                      border_enabled  "false"
                      border_char     "─"
                      border_format   "#[fg=#6C7086]{char}"
                      border_position "top"

                      mode_normal  "#[bg=blue] "
                      mode_tmux    "#[bg=#ffc387] "

                      tab_normal   "#[fg=#6C7086] {name} "
                      tab_active   "#[fg=#9399B2,bold,italic] {name} "

                      command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                      command_git_branch_format      "#[fg=blue] {stdout} "
                      command_git_branch_interval    "10"
                      command_git_branch_rendermode  "static"

                      datetime        "#[fg=#6C7086,bold] {format} "
                      datetime_format "%A, %d %b %Y %H:%M"
                      datetime_timezone "Europe/Berlin"
                  }
              }
          }

          swap_tiled_layout name="hsplit" {
              tab {
                  pane split_direction="horizontal" {
                      pane
                      pane
                  }
              }
          }
          swap_tiled_layout name="vsplit" {
              tab {
                  pane split_direction="vertical" {
                      pane
                      pane
                  }
              }
          }
      }
    '';

    # = {
    #   source = pkgs.stdenv.mkDerivation {
    #     pname = "zellij-layouts";
    #     version = "0.1";
    #     phases = ["patchPhase"];

    #     src = ./layouts;

    #     # TODO: replace commands with actual paths to binaries
    #     patchPhase = ''
    #       mkdir -p $out
    #       cp -r $src/* $out

    #       substituteInPlace $out/default.kdl \
    #         --replace '@user@' '${config.home.username}' \
    #         --replace '@barplugin@' '${barplugin}'

    #       substituteInPlace $out/vortrag.kdl \
    #         --replace '@user@' '${config.home.username}'
    #     '';
    #   };
    #   recursive = true;
    # };
  };
}
