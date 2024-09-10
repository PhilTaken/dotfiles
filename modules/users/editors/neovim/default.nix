{
  pkgs,
  config,
  lib,
  npins,
  ...
}: let
  cfg = config.phil.editors.neovim;
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (lib) mkOption mkIf types optionals;
  buildPlugin = attrset:
    buildVimPlugin ({
        version = "master";
        src = npins.${attrset.pname};
      }
      // attrset);

  plug = plugin: config: {
    inherit plugin config;
    type = "lua";
  };
  lplug = plugin: pconf: {
    inherit plugin;
    config = ''
      require("lz.n").load {
        "${plugin.pname}",
        ${pconf}
      }
    '';
    optional = true;
    type = "lua";
  };
  mkVlplug = plugin: (lplug plugin "event = 'DeferredUIEnter'");
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
        default = false;
      };

      cpp = mkOption {
        description = "enable the cpp integration";
        type = types.bool;
        default = false;
      };

      zig = mkOption {
        description = "enable the zig integration";
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
        default = false;
      };

      extra = mkOption {
        description = "enable extra integrations";
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables.EDITOR = "nvim";
    stylix.targets.vim.enable = false;

    # TODO add https://github.com/brenoprata10/nvim-highlight-colors
    programs.neovim = {
      defaultEditor = true;
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPython3Packages = ps: [ps.pynvim];
      extraPackages = with pkgs;
        [
          tree-sitter

          git # version control
          ripgrep # telescope file finding
          fd # faster find
          gcc # for treesitter

          bottom # custom floaterm

          inetutils # remote editing

          sumneko-lua-language-server
          stylua

          yaml-language-server

          # nix
          nil
          alejandra

          # formatting for hurl-nvim
          jq
          nodePackages.prettier

          # formatters for conform-nvim
        ]
        ++ (optionals cfg.langs.python [
          (pkgs.python3.withPackages (ps:
            with ps; [
              python-lsp-server
              pylsp-mypy
              python-lsp-ruff
              mypy
            ]))
          pkgs.mypy
          pkgs.ruff
          pkgs.isort
          pkgs.black
        ])
        ++ (optionals cfg.langs.ts [pkgs.nodePackages.typescript-language-server])
        ++ (optionals cfg.langs.cpp [pkgs.ccls])
        ++ (optionals cfg.langs.rust [pkgs.rust-analyzer-unwrapped])
        # ++ (optionals cfg.langs.zig [pkgs.zls])
        ++ (optionals cfg.langs.haskell [pkgs.haskell-language-server])
        ++ (optionals cfg.langs.extra (with pkgs; [
          fortls
          texlab
          #erlang-ls # erlang
          #elixir_ls # elixir
        ]));

      extraConfig = ''
        " write to undofile in undodir
        set undodir=${config.xdg.dataHome}
        set undofile

        luafile ~/.config/nvim/init_.lua
      '';

      # install treesitter with nix to prevent all kinds of libstdc++.so shenenigans
      plugins =
        (with pkgs.vimPlugins; [
          # these *need* to be loaded synchronously
          # ---------------------------------------
          lz-n
          vim-startuptime
          vim-sleuth
          plenary-nvim

          (plug nvim-navic ''
            require('nvim-navic').setup {
              icons = {
                File          = "󰈙 ",
                Module        = " ",
                Namespace     = "󰌗 ",
                Package       = ' ',
                Class         = ' ',
                Method        = ' ',
                Property      = ' ',
                Field         = ' ',
                Constructor   = " ",
                Enum          = ' ',
                Interface     = ' ',
                Function      = "󰊕 ",
                Variable      = ' ',
                Constant      = "󰏿 ",
                String        = "󰀬 ",
                Number        = "󰎠 ",
                Boolean       = ' ',
                Array         = ' ',
                Object        = ' ',
                Key           = "󰌋 ",
                Null          = "󰟢 ",
                EnumMember    = " ",
                Struct        = ' ',
                Event         = ' ',
                Operator      = "󰆕 ",
                TypeParameter = ' '
              }
            }
          '')

          (plug nvim-lspconfig ''
            require('custom.lsp')
          '')

          (plug catppuccin-nvim ''
            local catppuccin = require("catppuccin")
            catppuccin.setup({
                transparent_background = vim.g.neovide == nil,
                term_colors = true,
                compile = {
                    enable = true,
                },
                integrations = {
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

          (plug alpha-nvim ''
            require("custom.alpha")
          '')

          (plug galaxyline-nvim ''
            -- statusline
            require("custom.statusline")
          '')

          (plug nvim-treesitter.withAllGrammars ''
            require('nvim-treesitter.configs').setup {
              highlight = { enable = true },
              indent = { enable = true },
              auto_install = false,
            }
          '')

          (plug which-key-nvim ''
            require("which-key").setup({})
            require("custom.maps")
          '')

          # -----------------------------------------------------
          # these *should* to be loaded asynchronously
          # -----------------------------------------------------

          # telescope
          telescope-file-browser-nvim
          telescope-symbols-nvim
          telescope-zoxide
          telescope-ui-select-nvim
          (buildPlugin {pname = "telescope-egrepify.nvim";})
          # TODO lazily load extension before telescope-nvim
          (plug telescope-nvim ''
            require("telescope").load_extension("file_browser")
            require("telescope").load_extension("zoxide")
            require("telescope").load_extension("ui-select")
            require("telescope").load_extension("egrepify")
            require("custom.tele_init")
          '')
          neorg-telescope

          # completion
          (lplug luasnip ''
            after = function()
              require('custom.snippets')
            end
          '')

          (plug lspkind-nvim ''require('lspkind').init()'')

          cmp-buffer
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp-path
          cmp-under-comparator
          (buildPlugin {pname = "nvim-cmp-lsp-rs";})
          (plug nvim-cmp ''require("custom.cmp_init")'')

          # -----------------------------------------------------
          # these *are* loaded asynchronously
          # -----------------------------------------------------

          (lplug diffview-nvim ''
            after = function()
              vim.opt.fillchars:append { diff = "╱" }
              require('diffview').setup({})
            end,
            event = "DeferredUIEnter",
          '')

          (lplug neogit ''
            after = function()
              require("neogit").setup({
                  integrations = {
                      telescope = true,
                      diffview = true,
                  },
                  graph_style = "unicode",
              })
            end,
            command = "Neogit",
          '')

          (lplug vim-illuminate "event = 'DeferredUIEnter'")
          (lplug vim-rooter ''
            after = function()
              vim.g.rooter_targets = "/,*"
              vim.g.rooter_patterns = { ".git/", "Cargo.toml", ".envrc" }
              vim.g.rooter_resolve_links = 1
              vim.g.rooter_cd_cmd = 'lcd'
              vim.g.rooter_silent_chdir = 1
            end,
            event = "DeferredUIEnter",
          '')

          (lplug neorg ''
            after = function()
              require('neorg').setup{
                load = {
                  ["core.defaults"] = {},
                  ["core.concealer"] = {},
                  ["core.ui.calendar"] = {},
                  ["core.dirman"] = {
                    config = {
                      workspaces = {
                        notes = "~/Notes",
                      },
                      default_workspace = "notes",
                    },
                  },
                  ["core.integrations.telescope"] = {}
                },
              }
            end,
            event = "DeferredUIEnter",
          '')

          (lplug conform-nvim ''
            after = function()
              require('conform').setup{
                format_on_save = function(bufnr)
                  -- Disable with a global or buffer-local variable
                  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                  end
                  return { timeout_ms = 500, lsp_fallback = true }
                end,
                formatters_by_ft = {
                  lua = { "stylua" },
                  rust = { "rustfmt" },
                  python = { "isort", "black" },
                  nix = { "alejandra" },
                },
                formatters = {
                  rustfmt = {
                    command = "rustfmt",
                    args = { "-q", "--emit=stdout", "--unstable-features", "--skip-children", "--edition=2021" },
                  },
                },
              }

              vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                  -- FormatDisable! will disable formatting globally
                  vim.g.disable_autoformat = true
                  vim.notify("autoformat-on-save disabled globally", "info", { title = "conform.nvim" })
                else
                  vim.b.disable_autoformat = true
                  vim.notify("autoformat-on-save disabled in this buffer", "info", { title = "conform.nvim" })
                end
              end, {
                desc = "Disable autoformat-on-save",
                bang = true,
              })
              vim.api.nvim_create_user_command("FormatEnable", function()
                vim.notify("autoformat-on-save enabled", "info", { title = "conform.nvim" })
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
              end, {
                desc = "Re-enable autoformat-on-save",
              })
            end,
            event = "DeferredUIEnter",
          '')

          (lplug nvim-notify ''
            after = function()
              local notify = require("notify")
              notify.setup({ background_colour = "#000000" })
              vim.notify = notify
            end,
            event = "DeferredUIEnter",
          '')

          (lplug neoscroll-nvim ''
            after = function()
              require("neoscroll").setup({ hide_cursor = false })
            end,
            event = "DeferredUIEnter",
          '')

          (lplug stabilize-nvim ''
            after = function()
              require('stabilize').setup()
            end,
            event = "DeferredUIEnter",
          '')

          (lplug echodoc-vim ''
            before = function()
              vim.g["echodoc#enable_at_startup"] = 1
              vim.g["echodoc#type"] = 'floating'
            end,
            event = "DeferredUIEnter",
          '')

          (lplug float-preview-nvim ''
            before = function()
              vim.g["float_preview#docked"] = 1
            end,
            event = "DeferredUIEnter",
          '')

          (lplug indent-blankline-nvim ''
            after = function()
              require("ibl").setup({
                indent = { char = "│" },
                whitespace = { highlight = { "Whitespace", "NonText" } },
                exclude = {
                  buftypes = { "help", "terminal", "nofile", "nowrite" },
                  filetypes = { "startify", "dashboard", "man" },
                },
                scope = { show_start = false, show_end = false, }
              })
            end,
            event = "DeferredUIEnter",
          '')

          (lplug lsp_lines-nvim ''
            after = function()
              require("lsp_lines").setup()
              vim.diagnostic.config({
                  virtual_text = false,
                  virtual_lines = {
                      only_current_line = true,
                  },
              })
            end,
            event = "DeferredUIEnter",
          '')

          (lplug lsp_signature-nvim ''
            -- https://github.com/kevinhwang91/nvim-ufo#customize-fold-text
            after = function()
              require("lsp_signature").setup({
                  bind = true,
                  handler_opts = {
                      border = "single",
                  },
              })
            end,
            event = "DeferredUIEnter",
          '')

          (lplug nvim-bqf ''
            after = function()
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
            end,
            event = "DeferredUIEnter",
          '')

          (lplug pear-tree ''
            before = function()
              vim.g.pear_tree_smart_openers = 1
              vim.g.pear_tree_smart_closers = 1
              vim.g.pear_tree_smart_backspace = 1
              vim.g.pear_tree_map_special_keys = 0
              vim.g.pear_tree_ft_disabled = { "TelescopePrompt", "nofile", "terminal" }
            end,
            event = "DeferredUIEnter",
          '')

          (lplug gitlinker-nvim ''
            after = function()
              require("gitlinker").setup({
                  mappings = false,
                  callbacks = {
                      ["gitea%..*"] = require("gitlinker.hosts").get_gitea_type_url,
                      ["gitlab%..*"] = require("gitlinker.hosts").get_gitlab_type_url,
                  },
              })
            end,
            event = "DeferredUIEnter",
          '')

          (lplug gitsigns-nvim ''
            after = function()
              require('gitsigns').setup({})
            end,
            event = "DeferredUIEnter",
          '')

          (lplug nvim-tree-lua ''
            after = function()
              require("nvim-tree").setup({})
            end,
            event = "DeferredUIEnter",
          '')

          (lplug trouble-nvim ''
            after = function()
              require("trouble").setup({})
            end,
            event = "DeferredUIEnter",
          '')

          (lplug fidget-nvim ''
            after = function()
              require("fidget").setup{}
            end,
            event = "DeferredUIEnter",
          '')

          (lplug toggleterm-nvim ''
            after = function()
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
              require('custom.terminals')
            end,
            event = "DeferredUIEnter",
          '')

          (lplug vim-dadbod ''
            after = function()
              if vim.env.DATABASE_URL ~= nil then
                vim.env.DATABASE_URL = "sqlite:///" .. vim.env.DATABASE_URL
              end
            end,
            event = "DeferredUIEnter",
          '')

          (lplug vim-dadbod-completion ''
            after = function()
              vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                  pattern = {"*.sql"},
                  callback = function()
                    require('cmp').setup.buffer({
                      sources = {
                        { name = 'vim-dadbod-completion' }
                      }
                    })
                  end,
              })
            end,
            event = "DeferredUIEnter",
          '')

          # TODO required for lsp
          (plug nvim-web-devicons ''
            require("nvim-web-devicons").setup({
              override = {
                gleam = {
                  icon = "",
                  color = "#ffaff3",
                  name = "Gleam",
                },
              },
            })
          '')

          # filetype-specific plugins
          (lplug conjure ''
            before = function()
              vim.g["conjure#filetype#fennel"] = "conjure.client.fennel.stdio"
              vim.g["conjure#filetypes"] = { "clojure", "fennel", "janet", "hy", "julia", "racket", "scheme", "lisp" }
            end,
            ft = { "clj", "fnl", "janet", "hy", "julia", "rkt", "scm", "cl" },
          '')

          # missing pname
          parinfer-rust

          # TODO required for lsp
          SchemaStore-nvim

          (lplug fennel-vim ''ft = {"fennel"}'')
          (lplug vim-nix ''ft = {"nix"}'')
          (lplug vim-pandoc-syntax ''ft = {"md"}'')
        ])
        # plugins that aren't needed immediately for startup
        ++ (with pkgs.vimPlugins;
          map mkVlplug [
            lsp-colors-nvim
            targets-vim
            direnv-vim
            friendly-snippets
            nerdcommenter
            popup-nvim
            todo-comments-nvim
            vim-fugitive
            vim-repeat
            vim-surround
          ])
        ++ (with pkgs.vimExtraPlugins; [
          # this cannot be lazily loaded easily since neogit checks if it's available and adds some extra config if it is
          (plug nvim-ufo ''
            require('ufo').setup()
          '')

          (lplug vim-hy ''
            before = function()
              vim.g.hy_enable_conceal = 1
            end,
            ft = "hy",
          '')
          (lplug cybu-nvim ''
            after = function()
              require('cybu').setup({ display_time = 350 })
            end,
            event = "DeferredUIEnter",
          '')
        ])
        ++ (map (p: mkVlplug (buildPlugin p)) [
          # TODO add filetype here to only load them on demand
          {pname = "janet.vim";}
          {pname = "vim-terraform";}
          {pname = "yuck.vim";}
          {pname = "vim-varnish";}
        ])
        ++ (map buildPlugin [
          {pname = "promise-async";}
        ]);
    };

    home.packages = with pkgs; [
      #visidata
      neovim-remote
      #neovide
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

    xdg.configFile."nvim/ftdetect/" = {
      source = ./ftdetect;
      recursive = true;
    };

    xdg.configFile."neovide/config.toml".text = ''
      wsl = false
      no-multigrid = false
      vsync = true
      maximized = false
      srgb = true
      idle = true
      frame = "Full"
    '';
  };
}
