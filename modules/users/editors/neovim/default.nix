{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.editors.neovim;
in
{
  options.phil.editors.neovim = {
    enable = mkOption {
      description = "Enable the neovim module";
      type = types.bool;
      default = true;
    };

    langs = {
      python = mkOption {
        description = "enable the python integration";
        type = types.bool;
        default = false;
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
    home.sessionVariables = {
      EDITOR = "nvim";
      #PAGER = "${pkgs.nvimpager}/bin/nvimpager";
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPython3Packages = (ps: with ps; [ pynvim ]);
      extraPackages = with pkgs; [
        gcc11
        gcc-unwrapped

        tree-sitter

        git # version control
        ripgrep # telescope file finding
        fd # faster find
        gcc # for treesitter

        bottom # custom floaterm
        lazygit # lazy git managment

        neuron-notes # for zettelkasten note-taking

        sqlite # for sqlite.lua
        universal-ctags # ctags for anything

        inetutils # remote editing

        sumneko-lua-language-server # lua
        rnix-lsp # nix

      ]
      ++ optionals (cfg.langs.python) (with pkgs.python39Packages; [
        python-lsp-server
        python-lsp-black
        pyls-isort
        hy
      ])
      ++ (optionals (cfg.langs.ts) [ pkgs.nodePackages.typescript-language-server ])
      ++ (optionals (cfg.langs.cpp) [ pkgs.ccls ])
      ++ (optionals (cfg.langs.rust) [ pkgs.rust-analyzer ])
      ++ (optionals (cfg.langs.haskell) [ pkgs.haskell-language-server ])
      ++ (optionals (cfg.langs.extra) (with pkgs; [
        fortls
        erlang-ls
        texlab
        erlang-ls # erlang
        elixir_ls # elixir
        clojure-lsp # clojure
      ]));

      extraConfig = ''
        let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'"

        " write to undofile in undodir
        set undodir=${config.xdg.dataHome}
        set undofile

        luafile ~/.config/nvim/init_.lua
      '';
    };

    home.packages = with pkgs; [
      visidata
      #neovim-remote
      #(writeShellScriptBin "neovide-mg" "exec ${pkgs.neovide}/bin/neovide --multigrid")
      #neovide
    ];

    xdg.configFile."nvim/init_.lua".source = ./init.lua;
    xdg.configFile."goneovim/settings.toml".source = ./goneovim_settings.toml;

    home.file.".visidatarc".source = ./visidatarc;

    xdg.configFile."nvim/lua/" = {
      source = ./lua;
      recursive = true;
    };
  };
}
