{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.editors.helix;
in
{
  options.phil.editors.helix = {
    enable = mkOption {
      description = "Enable the helix module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;

      settings = {
        theme = "catppuccin_mocha";

        editor = {
          line-number = "relative";
          mouse = false;
        };

        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        editor.file-picker = {
          hidden = false;
        };

        editor.indent-guides = {
          render = true;
        };
      };
    };
  };
}
