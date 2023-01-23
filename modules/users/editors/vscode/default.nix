{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.editors.vscode;
in
{
  options.phil.editors.vscode = {
    enable = mkOption {
      description = "Enable the vscode module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        #ms-python.python
        ms-toolsai.jupyter
      ];
    };
  };
}
