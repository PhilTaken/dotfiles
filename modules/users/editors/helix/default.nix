{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types;
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
