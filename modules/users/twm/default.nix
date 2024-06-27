{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.twm;
  settingsFormat = pkgs.formats.yaml {};
  configFile = settingsFormat.generate "twm.yaml" cfg.settings;
in {
  options.phil.twm = {
    enable = mkEnableOption "twm";
    settings = lib.mkOption {
      type = lib.types.submodule {freeformType = settingsFormat.type;};
      default = {
        search_paths = ["~"];
        workspace_definitions = [
          {
            name = "default";
            has_any_file = [".git" ".twm.yaml"];
            default_layout = "default";
          }
        ];

        max_search_depth = 3;
        session_name_path_components = 2;
        exclude_path_components = [
          ".cache"
          ".cargo"
          ".git"
          "__pycache__"
          "node_modules"
          "target"
          "venv"
        ];

        layouts = [
          {
            name = "default";
            commands = ["echo 'Created $TWM_TYPE session"];
          }
        ];
      };
      description = ''
        The settings for twm in yaml format.
        Refer to <https://github.com/vinnymeller/twm/blob/master/doc/CONFIGURATION.md> for options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.twm];
    xdg.configFile."twm/twm.yaml".source = configFile;
  };
}
