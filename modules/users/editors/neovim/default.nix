{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.phil.editors.neovim;
  inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;
  inherit (lib) mkOption mkIf types optionals;
  buildPlugin = attrset: buildVimPluginFrom2Nix (attrset // {version = "master";});

  plug = plugin: config: {
    inherit plugin config;
    type = "lua";
  };
  lplug = plugin: pconf: {
    inherit plugin;
    config = ''
      vim.schedule(function()
        packadd("${plugin.pname}")
        ${pconf}
      end)
    '';
    optional = true;
    type = "lua";
  };
in {
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

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      #PAGER = "${pkgs.nvimpager}/bin/nvimpager";
    };

    stylix.targets.vim.enable = false;

    programs.neovim = {
      defaultEditor = true;
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPython3Packages = ps: with ps; [pynvim];
      extraPackages = with pkgs;
        [
          tree-sitter

          git # version control
          ripgrep # telescope file finding
          fd # faster find
          gcc # for treesitter

          bottom # custom floaterm
          lazygit # lazy git managment

          #emanote # for zettelkasten note-taking

          sqlite # for sqlite.lua
          inetutils # remote editing

          #sumneko-lua-language-server # lua

          nil # nix
          nixd # nix
        ]
        ++ (optionals cfg.langs.python (with pkgs.python3Packages; [python-lsp-server hy]))
        ++ (optionals cfg.langs.ts [pkgs.nodePackages.typescript-language-server])
        ++ (optionals cfg.langs.cpp [pkgs.ccls])
        ++ (optionals cfg.langs.rust [pkgs.rust-analyzer-unwrapped])
        ++ (optionals cfg.langs.haskell [pkgs.haskell-language-server])
        ++ (optionals cfg.langs.extra (with pkgs; [
          fortls
          texlab
          nimlsp
          #erlang-ls # erlang
          #elixir_ls # elixir
        ]));

      extraConfig = let
        sqlite_basename =
          if (lib.hasInfix "darwin" pkgs.system)
          then "libsqlite3.dylib"
          else "libsqlite3.so";
        sqlite_path = "${pkgs.sqlite.out}/lib/${sqlite_basename}";
      in ''
        let g:sqlite_clib_path = "${sqlite_path}"

        " write to undofile in undodir
        set undodir=${config.xdg.dataHome}
        set undofile

        luafile ~/.config/nvim/init_.lua
      '';

      extraLuaConfig = ''
        -- Source plugin and its configuration immediately
        -- @param plugin String with name of plugin as subdirectory in 'pack'
        local packadd = function(plugin)
          local command = 'packadd'
          vim.cmd(string.format([[%s %s]], command, plugin))
        end
      '';

      # install treesitter with nix to prevent all kinds of libstdc++ so shenenigans
      plugins =
        (with pkgs.vimPlugins; [
          (plug alpha-nvim ''
            require('alpha').setup(require('alpha.themes.startify').opts)
          '')
          (plug catppuccin-nvim ''
            local catppuccin = require("catppuccin")
            catppuccin.setup({
                transparent_background = true,
                term_colors = true,
                compile = {
                    enable = true,
                },
                dim_inactive = {
                    enabled = true,
                    percentage = 0.05,
                },
                --colorscheme = "dark_catppuccino",
                integrations = {
                    --lsp_saga = true,
                    markdown = true,
                    gitsigns = true,
                    telescope = true,
                    which_key = true,
                    nvimtree = true,
                    cmp = true,
                    treesitter = true,

                    indent_blankline = {
                        enabled = true,
                    },
                    native_lsp = {
                        enabled = true,
                    },
                },
            })
            vim.g.catppuccin_flavour = "mocha"
            vim.cmd([[colorscheme catppuccin]])
          '')

          (lplug neoscroll-nvim ''
            require("neoscroll").setup({ hide_cursor = false })
          '')

          (lplug nvim-colorizer-lua "require('colorizer').setup({})")

          (lplug stabilize-nvim "require('stabilize').setup()")

          (lplug echodoc-vim ''
            vim.cmd([[let g:echodoc#enable_at_startup = 1]])
            vim.cmd([[let g:echodoc#type = 'floating']])
          '')

          (lplug float-preview-nvim ''
            vim.cmd([[let g:float_preview#docked = 1]])
          '')

          (lplug indent-blankline-nvim ''
            require("indent_blankline").setup({
                buftype_exclude = { "help", "terminal", "nofile", "nowrite" },
                filetype_exclude = { "startify", "dashboard", "man" },
                show_current_context_start = true,
                use_treesitter = true,
            })
          '')

          (lplug lsp_lines-nvim ''
            require("lsp_lines").setup()
            vim.diagnostic.config({
                virtual_text = false,
                virtual_lines = {
                    only_current_line = true,
                },
            })
          '')

          (lplug lsp_signature-nvim ''
            -- https://github.com/kevinhwang91/nvim-ufo#customize-fold-text
            require("lsp_signature").setup({
                bind = true,
                handler_opts = {
                    border = "single",
                },
            })
          '')

          (plug lspkind-nvim "require('lspkind').init()")

          (lplug neogit ''
            require("neogit").setup({
                integrations = {
                    diffview = true,
                },
            })
          '')

          (lplug nvim-bqf ''
            -- Adapt fzf's delimiter in nvim-bqf
            require("bqf").setup({
                auto_resize_height = true,
                preview = {
                    win_height = 12,
                    win_vheight = 12,
                    delay_syntax = 80,
                    border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
                    show_title = false,
                },
                filter = {
                    fzf = {
                        extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│", "--prompt", "> " },
                    },
                },
            })
          '')

          (lplug pear-tree ''
            vim.g.pear_tree_smart_openers = 1
            vim.g.pear_tree_smart_closers = 1
            vim.g.pear_tree_smart_backspace = 1
            vim.g.pear_tree_map_special_keys = 0
            vim.g.pear_tree_ft_disabled = { "TelescopePrompt", "nofile", "terminal" }
          '')

          (plug vim-rooter ''
            vim.g.rooter_targets = "/,*"
            vim.g.rooter_patterns = { ".git/" }
            vim.g.rooter_resolve_links = 1
          '')

          (lplug conjure ''
            vim.cmd([[let g:conjure#filetype#fennel = "conjure.client.fennel.stdio"]])
          '')

          (lplug diffview-nvim "require('diffview').setup({})")
          (lplug gitlinker-nvim ''
            require("gitlinker").setup({
                mappings = false,
                callbacks = {
                    ["gitea%..*"] = require("gitlinker.hosts").get_gitea_type_url,
                    ["gitlab%..*"] = require("gitlinker.hosts").get_gitlab_type_url,
                },
            })
          '')

          (lplug gitsigns-nvim "require('gitsigns').setup({})")

          (lplug nvim-neoclip-lua ''
            require("neoclip").setup({ enable_persistent_history = true })
          '')

          (plug nvim-notify ''
            local notify = require("notify")
            notify.setup({ background_colour = "#000000" })
            vim.notify = notify
          '')

          (lplug nvim-tree-lua ''
            require("nvim-tree").setup({})
          '')

          (plug toggleterm-nvim ''
            require("toggleterm").setup({
                hide_numbers = true,
                shell = vim.o.shell,
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
            })
          '')

          (lplug trouble-nvim ''
            require("trouble").setup({})
          '')

          (lplug vim-pandoc ''
            vim.cmd([[let g:pandoc#spell#enabled = 0]])
          '')
          vim-pandoc-syntax

          (lplug telescope-nvim ''
            require("telescope").load_extension("git_worktree")
            require("telescope").load_extension("file_browser")
            require("telescope").load_extension("zoxide")
          '')
          telescope-file-browser-nvim
          telescope-symbols-nvim
          telescope-zoxide

          (plug which-key-nvim ''
            require("which-key").setup({})
          '')

          (plug fidget-nvim ''
            require("fidget").setup {
                text = {
                    spinner = "grow_vertical",
                },
            }
          '')

          # completion
          cmp-buffer
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp-path
          cmp-tmux
          cmp-under-comparator
          cmp_luasnip
          nvim-cmp

          nvim-treesitter.withAllGrammars
          friendly-snippets
          galaxyline-nvim
          git-worktree-nvim
          todo-comments-nvim
          vim-fugitive
          lsp-colors-nvim
          leap-nvim
          nvim-navic
          sqlite-lua
          targets-vim
          vim-nix
          vim-repeat
          vim-surround
          firenvim
          parinfer-rust
          vim-startuptime
          plenary-nvim
          popup-nvim
          luasnip
          nerdcommenter
          nvim-lspconfig
          nvim-web-devicons
          fennel-vim
          direnv-vim
        ])
        ++ (with pkgs.vimExtraPlugins; [
          (plug cybu-nvim ''
            require("cybu").setup({ display_time = 350 })
          '')
          (plug nvim-ufo "require('ufo').setup()")
          (plug vim-hy "vim.g.hy_enable_conceal = 1")
        ])
        ++ (map buildPlugin [
          # TODO: don't abuse nix flake inputs for these
          {
            pname = "janet.vim";
            src = inputs.vim-janet-src;
          }
          {
            pname = "vim-terraform";
            src = inputs.vim-terraform-src;
          }
          {
            pname = "yuck.vim";
            src = inputs.vim-yuck-src;
          }
          {
            pname = "promise-async";
            src = inputs.vim-async-src;
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

    xdg.configFile."nvim/syntax/" = {
      source = ./syntax;
      recursive = true;
    };
  };
}
