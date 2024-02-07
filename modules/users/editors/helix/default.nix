{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf;
  cfg = config.phil.editors.helix;
in {
  options.phil.editors.helix = {
    enable = mkOption {
      description = "enable helix";
      type = lib.types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;

      extraPackages = with pkgs; [
        tree-sitter # classic
        gcc # for treesitter

        nil # nix
        python3Packages.python-lsp-server # python
        #rust-analyzer-unwrapped # rust
        sumneko-lua-language-server # lua
      ];

      languages = {
        language-server.rust-analyzer.config = {
          files = {
            excludeDirs = [".direnv"];
            watcherExclude = [".direnv"];
          };
          imports = {
            granularity.group = "module";
            prefix = "self";
          };

          cargo.buildScripts.enable = true;
          procMacro.enable = true;

          check = {
            command = "clippy";
          };
        };
      };

      settings = {
        theme = "catppuccin_mocha";

        editor = {
          line-number = "relative";
          mouse = true;
          color-modes = true;
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
