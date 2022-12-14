{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.editors.neovim;
  inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;
  inherit (pkgs) fetchFromGitHub;
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

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      #PAGER = "${pkgs.nvimpager}/bin/nvimpager";
    };

    programs.neovim = {
      enable = true;
      #package = pkgs.neovim;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPython3Packages = ps: with ps; [ pynvim ];
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

        emanote # for zettelkasten note-taking

        sqlite # for sqlite.lua
        universal-ctags # ctags for anything

        inetutils # remote editing

        sumneko-lua-language-server # lua

        nil # nix
      ]
      ++ (optionals cfg.langs.python (with pkgs.python39Packages; [ python-lsp-server hy ]))
      ++ (optionals cfg.langs.ts [ pkgs.nodePackages.typescript-language-server ])
      ++ (optionals cfg.langs.cpp [ pkgs.ccls ])
      ++ (optionals cfg.langs.rust [ pkgs.rust-analyzer ])
      ++ (optionals cfg.langs.haskell [ pkgs.haskell-language-server ])
      ++ (optionals cfg.langs.extra (with pkgs; [
        fortls
        texlab
        #erlang-ls # erlang
        #elixir_ls # elixir
        #clojure-lsp # clojure
      ]));

      extraConfig = ''
        let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'"

        " write to undofile in undodir
        set undodir=${config.xdg.dataHome}
        set undofile

        luafile ~/.config/nvim/init_.lua
      '';

      # install treesitter with nix to prevent all kinds of libstdc++ so shenenigans
      plugins = (with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
        alpha-nvim
        catppuccin-nvim
        echodoc-vim
        float-preview-nvim
        friendly-snippets
        galaxyline-nvim
        git-worktree-nvim
        impatient-nvim
        indent-blankline-nvim
        lsp-colors-nvim
        lsp_lines-nvim
        lsp_signature-nvim
        lspkind-nvim
        luasnip
        neoscroll-nvim
        nerdcommenter
        nvim-colorizer-lua
        nvim-lspconfig
        nvim-web-devicons
        pear-tree
        plenary-nvim
        popup-nvim
        telescope-file-browser-nvim
        telescope-nvim
        telescope-symbols-nvim
        telescope-zoxide
        vim-gutentags
        vim-rooter
        vim-startuptime

        cmp-buffer
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        cmp-tmux
        cmp-under-comparator
        cmp_luasnip
        nvim-cmp

        Navigator-nvim
        conjure
        diffview-nvim
        direnv-vim
        fennel-vim
        gitlinker-nvim
        gitsigns-nvim
        hotpot-nvim
        leap-nvim
        nvim-navic
        nvim-neoclip-lua
        nvim-notify
        nvim-tree-lua
        sqlite-lua
        stabilize-nvim
        targets-vim
        toggleterm-nvim
        trouble-nvim
        vim-nix
        vim-pandoc
        vim-pandoc-syntax
        vim-repeat
        vim-surround
        which-key-nvim

        parinfer-rust
      ]) ++ (with pkgs.vimExtraPlugins; [
        cybu-nvim
        nvim-ufo
        vim-hy
        present-nvim
      ]) ++ (map buildVimPluginFrom2Nix [
        rec {
          pname = "janet.vim";
          version = "master";
          src = fetchFromGitHub {
            owner = "bakpakin";
            repo = pname;
            rev = "master";
            sha256 = "sha256-cySG6PuwlRfhNePUFdXP0w6m5GrYIxgMRcdpgFvJ+VA=";
          };
        }
        rec {
          pname = "vim-terraform";
          version = "master";
          src = fetchFromGitHub {
            owner = "hashivim";
            repo = pname;
            rev = "master";
            sha256 = "sha256-atyMKr5WChLBRDyO1KznH2LQzv5P+K+RQpQ71aeJB0k=";
          };
        }
        rec {
          pname = "yuck.vim";
          version = "master";
          src = fetchFromGitHub {
            owner = "elkowar";
            repo = pname;
            rev = "master";
            sha256 = "sha256-lp7qJWkvelVfoLCyI0aAiajTC+0W1BzDhmtta7tnICE=";
          };
        }
      ]);
    };

    home.packages = with pkgs; [
      visidata
      #neovim-remote

      # https://github.com/neovide/neovide/issues/1280
      # start neovide in xwayland for now
      (pkgs.writeShellApplication {
        name = "neovide";
        text = "WINIT_UNIX_BACKEND=x11 ${pkgs.neovide}/bin/neovide --multigrid";
      })
      (pkgs.makeDesktopItem {
        name = "Neovide";
        exec = "neovide";
        desktopName = "Neovide";
      })
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
