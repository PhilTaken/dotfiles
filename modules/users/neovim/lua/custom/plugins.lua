-- Install packer

local execute = vim.api.nvim_command
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
local install_packages = false

if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
    install_packages = true
end

-- Only required if you have packer in your `opt` pack
vim.cmd [[packadd packer.nvim]]

local use = require('packer').use
require('packer').startup{
    compile_path = vim.fn.stdpath('config')..'/lua/packer_compiled.lua',
    function()
        -- pack packer
        use {
            'wbthomason/packer.nvim',
            opt = true
        }

        -- add some startuptime hacks / improvements
        use {
            {
                'dstein64/vim-startuptime',
            },
            {
                'lewis6991/impatient.nvim',
                config = function()
                    require('impatient').enable_profile()
                end
            },
            {
                "nathom/filetype.nvim",
                config = function()
                    vim.g.did_load_filetypes = 1
                end
            },
        }

        -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        -- colorscheme ^-^
        use {
            {
                'catppuccin/nvim',
                config = function()
                    local catppuccin = require('catppuccin')
                    catppuccin.setup{
                        --colorscheme = "dark_catppuccino",
                        integrations = {
                            lsp_saga = true,
                            gitsigns = true,
                            telescope = true,
                            which_key = true,
                            nvimtree = {
                                enabled = true,
                            },
                            indent_blankline = {
                                enabled = true,
                                colored_indent_levels = true,
                            },
                            barbar = true,
                        },
                    }
                    -- catppuccino.load()
                    vim.cmd[[colorscheme catppuccin]]
                end
            },
            {
                'folke/lsp-colors.nvim',
            }
        }

        -- start menu
        use 'mhinz/vim-startify'
        -- dashboard.vim

        -- root vim in git dir
        use {
            'zah/vim-rooter',
            config = function()
                local g = vim.g
                g.rooter_targets = '/,*'
                g.rooter_patterns = { '.git/' }
                g.rooter_resolve_links = 1
            end
        }

        -- buffers visible above in a bar
        use {
            'romgrk/barbar.nvim',
            requires = {'kyazdani42/nvim-web-devicons'},
            event = "BufRead"
        }

        -- colorize color codes (e.g. #f2f34f)
        use {
            'norcalli/nvim-colorizer.lua',
            config = function()
                require('colorizer').setup()
            end,
            event = "BufEnter"
        }

        -- add visible indent aid
        use {
            "lukas-reineke/indent-blankline.nvim",
            requires = {
                'nvim-treesitter/nvim-treesitter',
            },
            config = function()
                require("indent_blankline").setup {
                    buftype_exclude = { "help", "terminal", "nofile", "nowrite" },
                    filetype_exclude = { "startify", "dashboard", "man" },
                    show_current_context = true,
                }
            end
        }

        -- smooth scrolling
        use({
            'karb94/neoscroll.nvim',
            event = 'WinScrolled',
            config = function()
                require('neoscroll').setup({ hide_cursor = false })
            end,
        })

        -- toggle comments in code
        use {
            -- numToStr/Comment.nvim
            'preservim/nerdcommenter',
            event = "BufRead"
        }

        -- auto end quotation mark/bracket
        use {
            'tmsvg/pear-tree',
            config = function()
                local g = vim.g
                g.pear_tree_smart_openers = 1
                g.pear_tree_smart_closers = 1
                g.pear_tree_smart_backspace = 1
                g.pear_tree_map_special_keys = 0
                g.pear_tree_ft_disabled = { 'TelescopePrompt', 'nofile', 'terminal' }
            end
        }

        -- show function arguments - floating!
        use {
            {
                "ray-x/lsp_signature.nvim"
            },
            {
                'Shougo/echodoc.vim',
                config = function()
                    local cmd = vim.cmd
                    cmd[[let g:echodoc#enable_at_startup = 1]]
                    cmd[[let g:echodoc#type = 'floating']]
                end
            },
            {
                'ncm2/float-preview.nvim',
                config = function()
                    vim.cmd[[let g:float_preview#docked = 1]]
                end,
                event = "InsertEnter"
            }
        }

        -- telescope
        use {
            {
                'nvim-telescope/telescope.nvim',
                requires = {
                    {'nvim-lua/popup.nvim'},
                    {'nvim-lua/plenary.nvim'}
                },
                config = function()
                    require('custom.tele_init')
                end,
                event = "CursorHold"
            },
            {
                'nvim-telescope/telescope-symbols.nvim',
                after = 'telescope.nvim',
            },
        }

        -- statusline
        use {
            'glepnir/galaxyline.nvim',
            branch = 'main',
            config = function()
                require'custom.statusline'
            end,
            requires = {'kyazdani42/nvim-web-devicons', opt = true},
            event = "BufEnter",
        }

        -- mark specific comments for
        use {
            "folke/todo-comments.nvim",
            requires = "nvim-lua/plenary.nvim",
            config = function()
                require("todo-comments").setup {}
            end
        }

        -- fancy syntax hl for md files
        use {
            'vim-pandoc/vim-pandoc',
            requires = 'vim-pandoc/vim-pandoc-syntax',
            config = function()
                vim.cmd[[let g:pandoc#spell#enabled = 0]]
            end,
            ft = { "markdown", "pandoc" },
        }

        -- config for the builtin language server
        use {
            'neovim/nvim-lspconfig',
            event = 'BufRead',
            config = function()
                require('custom.lsp')
            end,
            requires = {
                { "hrsh7th/cmp-nvim-lsp" },
                {
                    'onsails/lspkind-nvim',
                    config =  function()
                        require'lspkind'.init()
                    end
                },
            }
        }

        -- generate comments / docs from code
        use {
            "danymat/neogen",
            config = function()
                require('neogen').setup{
                    enabled = true,
                }
            end,
            requires = "nvim-treesitter/nvim-treesitter",
            module = "neogen",
        }

        -- extra fancy lsp extras
        use {
            'glepnir/lspsaga.nvim',
            config = function()
                local saga = require 'lspsaga'
                saga.init_lsp_saga{
                    code_action_icon = ' ',
                    code_action_prompt = {
                      enable = true,
                      sign = false,
                      sign_priority = 20,
                      virtual_text = false,
                    },
                }
            end
        }

        -- ast-like code parsing utility for hl / indent / lsp
        use {
            'nvim-treesitter/nvim-treesitter',
            run = ":TSUpdate",
            config = function()
                require'nvim-treesitter.configs'.setup {
                    ensure_installed = "maintained",
                    highlight = {
                        enable = true,
                    },
                }
            end
        }

        -- completion management
        use {
            'hrsh7th/nvim-cmp',
            Event = "InsertEnter",
            requires = {
                {
                    "L3MON4D3/LuaSnip",
                    event = "CursorHold",
                    config = function()
                        require('custom.snippets')
                    end,
                    requires = { 'rafamadriz/friendly-snippets' },
                },
                { "hrsh7th/cmp-buffer", after = "nvim-cmp"},
                { "hrsh7th/cmp-path", after = "nvim-cmp" },
                { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" },
                { "lukas-reineke/cmp-under-comparator" },
                { 'andersevenrud/compe-tmux', branch = 'cmp', after = "nvim-cmp" },
                { 'saadparwaiz1/cmp_luasnip', after = "nvim-cmp" },
            },
            config = function()
                require'custom.cmp_init'
            end
        }

        -- direnv sourcing in nvim
        use {
            "direnv/direnv.vim",
            event = "BufEnter"
        }

        -- shareable git links
        use {
            'ruifm/gitlinker.nvim',
            requires = 'nvim-lua/plenary.nvim',
            config = function()
                require("gitlinker").setup{
                    mappings = nil
                }
            end,
            module = "gitlinker",
        }

        -- nix
        use {
            'LnL7/vim-nix',
            ft = "nix"
        }

        -- extra targets
        use {
            'wellle/targets.vim',
            event = "BufEnter"
        }

        use {
            'lewis6991/gitsigns.nvim',
            requires = { 'nvim-lua/plenary.nvim' },
            tag = 'v0.2',
            config = function()
                require('gitsigns').setup {
                    signs = {
                        add          = {hl = 'GitGutterAdd'   , text = '+'},
                        change       = {hl = 'GitGutterChange', text = '~'},
                        delete       = {hl = 'GitGutterDelete', text = '_'},
                        topdelete    = {hl = 'GitGutterDelete', text = '‾'},
                        changedelete = {hl = 'GitGutterChange', text = '~'},
                    }
                }
            end,
            event = "BufEnter"
        }

        -- extra icons for completion
        -- manage surrounds e.g. quotation marks, html tags, ...
        use {
            'tpope/vim-surround',
            event = "BufRead",
            requires = {
                {
                    'tpope/vim-repeat',
                    event = 'BufRead',
                },
            },
        }

        use {
            'jalvesaq/Nvim-R',
            config = function()
                local cmd = vim.cmd
                cmd[[let R_non_r_compl = 0]]
                cmd[[let R_user_maps_only = 1]]
                cmd[[let R_csv_app = 'tmux new-window vd']]
                cmd[[let R_auto_start = 1]]
            end,
            ft = { "r", "rmd" },
        }

        -- show keybinds + comment for them
        use {
            "folke/which-key.nvim",
            config = function()
                require'which-key'.setup{}
            end,
        }

        -- diagnostic pretty window
        use {
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
            config = function()
                require('trouble').setup{}
            end,
            event = "CursorHold"
        }

        -- navigate to tmux and back
        use {
            'numToStr/Navigator.nvim',
            config = function()
                require("Navigator").setup({
                    auto_save = 'all',
                    disable_on_zoom = true,
                })
            end,
            event = "BufEnter"
        }

        -- for repls in vim
        use {
            'hkupty/iron.nvim',
            config = function()
                local iron = require('iron')

                iron.core.add_repl_definitions {
                    python = {
                        ipython = {
                            command = { "ipython", "--no-autoindent" }
                        }
                    }
                }

                iron.core.set_config {
                    preferred = {
                        python = "ipython",
                    }
                }
            end,
            ft = { "python" }
        }

        -- floating terminals
        use {
            "akinsho/toggleterm.nvim",
            config = function()
                require('toggleterm').setup{}
            end,
        }

        -- file tree
        use {
            'kyazdani42/nvim-tree.lua',
            requires = 'kyazdani42/nvim-web-devicons',
            config = function()
                require'nvim-tree'.setup {
                    auto_close = true,
                }
            end,
            cmd = "NvimTreeToggle",
        }

        -- stabilize the main window when opening others
        use {
            "luukvbaal/stabilize.nvim",
            config = function()
                require("stabilize").setup()
            end,
            event = "BufEnter"
        }

        -- clipboard manager
        use {
            "AckslD/nvim-neoclip.lua",
            requires = {'tami5/sqlite.lua', module = 'sqlite'},
            config = function()
                require('neoclip').setup{
                    enable_persistant_history = true,
                }
                require'lspkind'.init()
            end,
            module = "telescope",
        }

        -- crazy fast movement
        use {
            'ggandor/lightspeed.nvim',
            event = "BufRead"
        }

        -- ideas:
        -- rust-tools.nvim
    end,
    config = {
        display = {
            open_fn = function ()
                return require('packer.util').float({border = 'single'})
            end
        }
    }
}

-- install updates if packer has just been downloaded
if install_packages then
    execute("PackerInstall")
end
