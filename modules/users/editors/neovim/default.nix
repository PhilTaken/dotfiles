{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.editors.neovim;
  inherit (pkgs.neovimUtils) buildNeovimPluginFrom2Nix;
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
      package = pkgs.neovim;
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

        neuron-notes # for zettelkasten note-taking

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

      # install treesitter with nix to prevent all kinds of libstdc++ so shenenigans
      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
        impatient-nvim
        vim-startuptime
        lsp-colors-nvim
        nvim-web-devicons
        plenary-nvim
        popup-nvim
        telescope-nvim
        telescope-symbols-nvim
        catppuccin-nvim
        alpha-nvim
        vim-gutentags
        vim-rooter
        nvim-colorizer-lua
        indent-blankline-nvim
        neoscroll-nvim
        nerdcommenter
        pear-tree
        git-worktree-nvim
        telescope-file-browser-nvim
        telescope-zoxide
        galaxyline-nvim
        nvim-lspconfig
        echodoc-vim
        float-preview-nvim
        lsp_lines-nvim
        lspkind-nvim
        luasnip
        friendly-snippets
        lsp_signature-nvim

        nvim-cmp
        cmp-nvim-lsp
        cmp_luasnip
        cmp-buffer
        cmp-path
        cmp-nvim-lua
        cmp-under-comparator
        cmp-tmux

        direnv-vim
        gitlinker-nvim
        vim-nix
        fennel-vim
        conjure
        vim-pandoc
        vim-pandoc-syntax
        targets-vim
        gitsigns-nvim
        diffview-nvim
        nvim-notify
        vim-surround
        vim-repeat
        which-key-nvim
        trouble-nvim
        Navigator-nvim
        toggleterm-nvim
        nvim-tree-lua
        stabilize-nvim
        nvim-neoclip-lua
        sqlite-lua
        hotpot-nvim
        # TODO: flakify neovim config with plugin inputs
        (buildVimPluginFrom2Nix rec {
          pname = "nvim-navic";
          version = "master";
          src = fetchFromGitHub {
            owner = "SmiteshP";
            repo = pname;
            rev = "master";
            sha256 = "sha256-OzzH/DNZk2g8HPbYw6ulM+ScxQW6NU3YZxTgLycWQOM=";
          };
        })
        (buildVimPluginFrom2Nix rec {
          pname = "promise-async";
          version = "master";
          src = fetchFromGitHub {
            owner = "kevinhwang91";
            repo = pname;
            rev = "master";
            sha256 = "sha256-rGbi5nCCz1qO6CzoWxbze8iKWP6baqIZBd/Je2LU6jw=";
          };
        })
        (buildVimPluginFrom2Nix rec {
          pname = "nvim-ufo";
          version = "master";
          src = fetchFromGitHub {
            owner = "kevinhwang91";
            repo = pname;
            rev = "master";
            sha256 = "sha256-vH6I3kImt96ZqMuzQpIfnF057Fw6/iXNPoTHJ/lSLBM=";
          };
        })
        (buildVimPluginFrom2Nix rec {
          pname = "janet.vim";
          version = "master";
          src = fetchFromGitHub {
            owner = "bakpakin";
            repo = pname;
            rev = "master";
            sha256 = "sha256-7euLzQxPuT9uUzwP5NWU+xBSyHz4AscHhqpdwCusewc=";
          };
        })
        (buildVimPluginFrom2Nix rec {
          pname = "vim-hy";
          version = "master";
          src = fetchFromGitHub {
            owner = "hylang";
            repo = pname;
            rev = "master";
            sha256 = "sha256-j3Y9gWFAlaUrvoUO8BwkAJor9uzIjCXIKcg1jTwzOjA=";
          };
        })
        (buildVimPluginFrom2Nix rec {
          pname = "yuck.vim";
          version = "master";
          src = fetchFromGitHub {
            owner = "elkowar";
            repo = pname;
            rev = "master";
            sha256 = "sha256-lp7qJWkvelVfoLCyI0aAiajTC+0W1BzDhmtta7tnICE=";
          };
        })
        (buildVimPluginFrom2Nix rec {
          pname = "leap.nvim";
          version = "master";
          src = fetchFromGitHub {
            owner = "ggandor";
            repo = pname;
            rev = "master";
            sha256 = "sha256-JGRU9aktCLpmEjNM+5EQQSQyxLENthfsVBdNjaDiziY=";
          };
        })
        (buildVimPluginFrom2Nix rec {
          pname = "cybu.nvim";
          version = "master";
          src = fetchFromGitHub {
            owner = "ghillb";
            repo = pname;
            rev = "master";
            sha256 = "sha256-mSJdHx+pzKqp2ImugTmMVuC+xAjJKcCGgd+JfBy636Q=";
          };
        })

        # for parinfer
        packer-nvim
      ];
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
