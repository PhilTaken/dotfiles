{
  pkgs,
  config,
  lib,
  npins,
  ...
}: let
  cfg = config.phil.editors.neovim;
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (lib) mkOption mkIf types optionals optional;
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
  lplug1 = plugin: pconf: preconf: {
    inherit plugin;
    config = ''
      vim.schedule(function()
        ${preconf}
        packadd("${plugin.pname}")
        ${pconf}
      end)
    '';
    optional = true;
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
  mkLplug = plugin: (lplug plugin "");
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

          sqlite # for sqlite.lua
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

      # install treesitter with nix to prevent all kinds of libstdc++.so shenenigans
      plugins =
        (with pkgs.vimPlugins; [
          # ---------------------------------------
          # these *need* to be loaded synchronously
          (plug nvim-treesitter.withAllGrammars ''
            require('nvim-treesitter.configs').setup {
              highlight = { enable = true },
              indent = { enable = true },
            }
          '')
          (plug alpha-nvim ''
            require('alpha').setup(require('alpha.themes.startify').opts)
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

          (plug vim-rooter ''
            vim.g.rooter_targets = "/,*"
            vim.g.rooter_patterns = { ".git/" }
            vim.g.rooter_resolve_links = 1
          '')

          # -----------------------------------------------------

          (lplug vim-illuminate ''
            require('illuminate').configure{}
          '')

          (lplug neorg ''
            require('neorg').setup{
              load = {
                ["core.defaults"] = {},
                ["core.concealer"] = {},
                ["core.dirman"] = {
                  config = {
                    workspaces = {
                      notes = "~/Notes",
                    },
                    default_workspace = "notes",
                  },
                },
              },
            }
          '')
          # extra plugins for *neorg*
          #lua-utils-nvim
          nvim-nio
          #pathlib-nvim

          (lplug conform-nvim ''
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
          '')

          (lplug nvim-notify ''
            local notify = require("notify")
            notify.setup({ background_colour = "#000000" })
            vim.notify = notify
          '')

          (lplug neoscroll-nvim ''
            require("neoscroll").setup({ hide_cursor = false })
          '')

          (lplug nvim-colorizer-lua "require('colorizer').setup({})")

          (lplug stabilize-nvim "require('stabilize').setup()")

          (lplug1 echodoc-vim "" ''
            vim.g["echodoc#enable_at_startup"] = 1
            vim.g["echodoc#type"] = 'floating'
          '')

          (lplug1 float-preview-nvim "" ''
            vim.g["float_preview#docked"] = 1
          '')

          (lplug indent-blankline-nvim ''
            require("ibl").setup({
              indent = { char = "│" },
              whitespace = { highlight = { "Whitespace", "NonText" } },
              exclude = {
                buftypes = { "help", "terminal", "nofile", "nowrite" },
                filetypes = { "startify", "dashboard", "man" },
              },
              scope = { show_start = false, show_end = false, }
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

          (lplug glow-nvim ''
            require('glow').setup({
              glow_path = "${pkgs.glow}/bin/glow",
            })
          '')

          (plug neogit ''
            require("neogit").setup({
                integrations = {
                    telescope = true,
                    diffview = true,
                },
                graph_style = "unicode",
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

          (lplug1 pear-tree "" ''
            vim.g.pear_tree_smart_openers = 1
            vim.g.pear_tree_smart_closers = 1
            vim.g.pear_tree_smart_backspace = 1
            vim.g.pear_tree_map_special_keys = 0
            vim.g.pear_tree_ft_disabled = { "TelescopePrompt", "nofile", "terminal" }
          '')

          (lplug1 conjure "" ''
            vim.g["conjure#filetype#fennel"] = "conjure.client.fennel.stdio"
            vim.g["conjure#filetypes"] = { "clojure", "fennel", "janet", "hy", "julia", "racket", "scheme", "lisp" }
          '')

          (plug diffview-nvim ''
            vim.opt.fillchars:append { diff = "╱" }
            require('diffview').setup({})
          '')

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

          (lplug nvim-tree-lua ''
            require("nvim-tree").setup({})
          '')

          (lplug trouble-nvim ''
            require("trouble").setup({})
          '')

          (lplug vim-pandoc ''
            vim.g["pandoc#spell#enabled"] = 0
          '')

          (lplug fidget-nvim ''
            require("fidget").setup{}
          '')

          # TODO load extension asynchronously but before telescope-nvim
          (plug telescope-nvim ''
            require("telescope").load_extension("file_browser")
            require("telescope").load_extension("zoxide")
            require("telescope").load_extension("ui-select")
          '')
          telescope-file-browser-nvim
          telescope-symbols-nvim
          telescope-zoxide
          telescope-ui-select-nvim

          # TODO load these asynchronously
          (plug lspkind-nvim "require('lspkind').init()")
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

          (plug which-key-nvim ''
            require("which-key").setup({})
          '')

          (plug (buildPlugin {pname = "telescope-egrepify.nvim";}) ''
            require "telescope".load_extension "egrepify"
          '')

          (plug nui-nvim "")

          (plug (buildPlugin {pname = "hurl-nvim";}) ''
            require("hurl").setup({
              mode = "split",
              formatters = {
                json = { 'jq' },
                html = {
                  'prettier',
                  '--parser',
                  'html',
                },
              },
            })
          '')

          # completion
          cmp-buffer
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp-path
          cmp-under-comparator
          cmp_luasnip
          nvim-cmp

          galaxyline-nvim
          vim-startuptime
          plenary-nvim
          nvim-lspconfig
          nvim-web-devicons
          luasnip
          vim-sleuth

          parinfer-rust
          nvim-navic

          # json/yaml schemas for lsp
          SchemaStore-nvim
        ])
        # plugins that aren't needed immediately for startup
        ++ (with pkgs.vimPlugins;
          map mkLplug [
            lsp-colors-nvim
            sqlite-lua
            targets-vim
            direnv-vim
            fennel-vim
            firenvim
            friendly-snippets
            leap-nvim
            nerdcommenter
            popup-nvim
            todo-comments-nvim
            vim-fugitive
            vim-nix
            vim-pandoc-syntax
            vim-repeat
            vim-surround
          ])
        ++ (with pkgs.vimExtraPlugins; [
          (lplug cybu-nvim "require('cybu').setup({ display_time = 350 })")
          (plug nvim-ufo ''
            require('ufo').setup()
          '')
          (lplug vim-hy "vim.g.hy_enable_conceal = 1")
        ])
        ++ (map (p: mkLplug (buildPlugin p)) [
          # TODO: don't abuse nix flake inputs for these
          {pname = "janet.vim";}
          {pname = "vim-terraform";}
          {pname = "yuck.vim";}
          {pname = "vim-varnish";}
        ])
        ++ (map buildPlugin [
          {pname = "promise-async";}
        ]);
    };

    home.shellAliases.g = "vim +Neogit";

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
