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

    # TODO generate all of the below with nix
    # TODO colors from stylix
    xdg.configFile."zellij/config.kdl" = {
      source = settings.configFile;
    };

    # TODO add dimsum duration in bar
    xdg.configFile."zellij/layouts/default.kdl".text = ''
      layout {
          default_tab_template {
              pane size=2 borderless=true {
                  plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                      mode_normal  "#[bg=#1e1e2e,fg=#cad3f5]"
                      mode_tmux    "#[bg=#1e1e2e,fg=#fab387]"

                      tab_normal   "#[fg=#1e1e2e,bg=#cad3f5]#[bg=#cad3f5,fg=#313244] {index}  {name} #[bg=#1e1e2e,fg=#cad3f5]"
                      tab_active   "#[fg=#1e1e2e,bg=#89b4fa]#[bg=#89b4fa,fg=#313244]#[bold,italic,bg=#89b4fa,fg=#313244] {index}  {name} #[bg=#1e1e2e,fg=#89b4fa]"

                      format_left  "{mode}{tabs}"

                      format_right "{command_dimsum_note}#[bg=#1e1e2e] #[fg=#1e1e2e,bg=#585b70]{datetime}"
                      format_space "#[bg=#1e1e2e]"

                      border_enabled  "true"
                      border_char     "─"
                      border_format   "#[fg=#181825]{char}"
                      border_position "bottom"

                      command_dimsum_note_command     "bash -c \"dimsum status --json | jq -r '.note' | grep -v null\""
                      command_dimsum_note_format      "#[fg=#cdd6f4,bg=#1e1e2e]{stdout}"
                      command_dimsum_note_interval    "10"
                      command_dimsum_note_rendermode  "static"

                      datetime        "#[bg=#585b70,fg=#cdd6f4,bold] {format} "
                      datetime_format "%A, %d %b %Y %H:%M"
                      datetime_timezone "Europe/Berlin"
                  }
              }
              children
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
  };
}
