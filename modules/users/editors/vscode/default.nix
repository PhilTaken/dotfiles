{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.editors.vscode;
in
{
  options.phil.editors.vscode = {
    enable = mkEnableOption "vscode";
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
