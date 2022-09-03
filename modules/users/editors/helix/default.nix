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

    langs = {
      python = mkOption {
        description = "enable the python integration";
        type = types.bool;
        default = true;
      };

      ts = mkOption {
        description = "enable the js/ts integration";
        type = types.bool;
        default = true;
      };

      cpp = mkOption {
        description = "enable the cpp integration";
        type = types.bool;
        default = true;
      };

      rust = mkOption {
        description = "enable the rust integration";
        type = types.bool;
        default = true;
      };

      haskell = mkOption {
        description = "enable the haskell integration";
        type = types.bool;
        default = true;
      };

      extra = mkOption {
        description = "enable extra integrations";
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf (cfg.enable) {
    #home.sessionVariables = {
      #EDITOR = "nvim";
    #};

    programs.helix = {
      enable = true;

      settings = {
        theme = "onedark";

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

      #extraPackages = with pkgs; [
        #gcc11
        #gcc-unwrapped

        #tree-sitter

        #git # version control
        #ripgrep # telescope file finding
        #fd # faster find
        #gcc # for treesitter

        #bottom # custom floaterm
        #lazygit # lazy git managment

        #neuron-notes # for zettelkasten note-taking

        #sqlite # for sqlite.lua
        #universal-ctags # ctags for anything

        #inetutils # remote editing

        #sumneko-lua-language-server # lua
        #rnix-lsp # nix

      #]
      #++ (optionals (cfg.langs.python) (with pkgs.python39Packages; [ python-lsp-server hy ]))
      #++ (optionals (cfg.langs.ts) [ pkgs.nodePackages.typescript-language-server ])
      #++ (optionals (cfg.langs.cpp) [ pkgs.ccls ])
      #++ (optionals (cfg.langs.rust) [ pkgs.rust-analyzer ])
      #++ (optionals (cfg.langs.haskell) [ pkgs.haskell-language-server ])
      #++ (optionals (cfg.langs.extra) (with pkgs; [
        #fortls
        #erlang-ls
        #texlab
        #erlang-ls # erlang
        #elixir_ls # elixir
        #clojure-lsp # clojure
      #]));
    };
  };
}
