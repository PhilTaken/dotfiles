{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.editors.helix;
in
{
  options.phil.editors.helix = {
    enable = mkEnableOption "helix";
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
