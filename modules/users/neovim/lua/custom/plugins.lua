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
        use {'wbthomason/packer.nvim', opt = true}

        use 'dstein64/vim-startuptime'


        use {
            'romgrk/barbar.nvim',
            requires = {'kyazdani42/nvim-web-devicons'}
        }

        -- change pwd to git root
        use {
            'zah/vim-rooter',
            config = function()
                local g = vim.g
                g.rooter_targets = '/,*'
                g.rooter_patterns = { '.git/' }
                g.rooter_resolve_links = 1
            end
        }

        -- start menu
        use 'mhinz/vim-startify'

        use {
            'norcalli/nvim-colorizer.lua',
            config = function()
                require('colorizer').setup()
            end
        }

        use {
            "lukas-reineke/indent-blankline.nvim",
            requires = {
                'nvim-treesitter/nvim-treesitter',
            },
            config = function()
                require("indent_blankline").setup {
                    --char = "|",
                    buftype_exclude = { "help", "terminal", "nofile", "nowrite" },
                    filetype_exclude = { "startify", "dashboard", "man" },
                    show_current_context = true,
                }
            end
        }

        -- commenting
        use 'preservim/nerdcommenter'

        -- auto end quotation mark/bracket
        --use 'cohama/lexima.vim'
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

        -- use 'jiangmao/auto-pairs'
        -- specifically https://github.com/jiangmiao/auto-pairs/blob/master/plugin/auto-pairs.vim

        -- show function arguments
        use {
            'Shougo/echodoc.vim',
            config = function()
                local cmd = vim.cmd
                cmd[[let g:echodoc#enable_at_startup = 1]]
                cmd[[let g:echodoc#type = 'floating']]
            end
        }

        -- telescope
        use {
            'nvim-telescope/telescope.nvim',
            requires = {
                {'nvim-lua/popup.nvim'},
                {'nvim-lua/plenary.nvim'}
            },
            config = function()
                require('custom.tele_init')
            end
        }

        -- statusline
        use {
            'glepnir/galaxyline.nvim',
            branch = 'main',
            config = function()
                require'custom.statusline'
            end,
            requires = {'kyazdani42/nvim-web-devicons', opt = true}
        }

        use 'folke/lsp-colors.nvim'

        use {
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
        }

        --use {
        --    'ayu-theme/ayu-vim',
        --    config = function()
        --        vim.g.ayucolor = "mirage"
        --        vim.cmd[[colorscheme ayu]]
        --    end
        --}

        use {
            "folke/todo-comments.nvim",
            requires = "nvim-lua/plenary.nvim",
            config = function()
                require("todo-comments").setup {}
            end
        }

        use {
            'lewis6991/impatient.nvim',
            config = function()
                require('impatient').enable_profile()
            end
        }

        use {
            "nathom/filetype.nvim",
            config = function()
                vim.g.did_load_filetypes = 1
            end
        }

        use {
            'vim-pandoc/vim-pandoc',
            config = function()
                vim.cmd[[let g:pandoc#spell#enabled = 0]]
            end
        }
        use 'vim-pandoc/vim-pandoc-syntax'

        -- ultisnips alternative in lua
        --use 'norcalli/snippets.nvim'

        -- config for the builtin language server
        use 'neovim/nvim-lspconfig'

        use {
            "danymat/neogen",
            config = function()
                require('neogen').setup{
                    enabled = true,
                }
            end,
            requires = "nvim-treesitter/nvim-treesitter"
        }

        -- lspsaga
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

        -- signature help
        use {
            "ray-x/lsp_signature.nvim",
        }

        -- treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            run = ":TSUpdate",
            config = function()
                -- setup treesitter
                require'nvim-treesitter.configs'.setup {
                    ensure_installed = "maintained",
                    highlight = {
                        enable = true,
                    },
                }
            end
        }

        use {
            "L3MON4D3/LuaSnip",
            config = function()
                require('custom.snippets')
            end
        }

        -- completion management
        use {
            'hrsh7th/nvim-cmp',
            requires = {
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-nvim-lua",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-latex-symbols",
                "lukas-reineke/cmp-under-comparator",
                { 'andersevenrud/compe-tmux', branch = 'cmp' },
                'saadparwaiz1/cmp_luasnip',
                'onsails/lspkind-nvim',
            },
            config = function()
                require'lspkind'.init()
                require'custom.cmp_init'
            end
        }

        -- direnv sourcing in nvim
        use "direnv/direnv.vim"

        -- shareable git links
        use {
            'ruifm/gitlinker.nvim',
            requires = 'nvim-lua/plenary.nvim',
            config = function()
                require("gitlinker").setup{
                    mappings = nil
                }
            end,
        }

        -- completion with docked floating windows
        use {
            'ncm2/float-preview.nvim',
            config = function()
                vim.cmd[[let g:float_preview#docked = 1]]
            end
        }

        -- nix
        use 'LnL7/vim-nix'

        -- extra targets
        use 'wellle/targets.vim'

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
            end
        }

        -- extra icons for completion
        -- manage surrounds e.g. quotation marks, html tags, ...
        use 'tpope/vim-surround'

        -- highlighting for the glsl (gl shader language)
        --use 'tikhomirov/vim-glsl'

        use {
            'jalvesaq/Nvim-R',
            config = function()
                local cmd = vim.cmd
                cmd[[let R_non_r_compl = 0]]
                cmd[[let R_user_maps_only = 1]]
                cmd[[let R_csv_app = 'tmux new-window vd']]
                cmd[[let R_auto_start = 1]]
            end
        }


        -- show keybinds + comment for them
        use {
            "folke/which-key.nvim",
            config = function()
                require'which-key'.setup{}
            end,
        }

        -- quick peek to certain line numbers
        use {
            'nacro90/numb.nvim',
            config = function()
                require('numb').setup()
            end,
        }

        use {
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
            config = function()
                require('trouble').setup{}
            end,
        }

        use {
            'numToStr/Navigator.nvim',
            config = function()
                require("Navigator").setup({
                    auto_save = 'all',
                    disable_on_zoom = true,
                })
            end
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
            end
        }

        -- lazygit
        use {
            'kdheepak/lazygit.nvim',
            requires = 'nvim-lua/plenary.nvim'
        }

        use {
            "akinsho/toggleterm.nvim",
            config = function()
                require('toggleterm').setup{}
            end
        }

        use {
            'kyazdani42/nvim-tree.lua',
            requires = 'kyazdani42/nvim-web-devicons',
            config = function()
                require'nvim-tree'.setup {
                    auto_close = true,
                }
            end
        }

        use {
            "luukvbaal/stabilize.nvim",
            config = function() require("stabilize").setup() end
        }


        -- auto resize for splits
        -- use {
        --     "beauwilliams/focus.nvim",
        --     config = function()
        --         require("focus").setup{
        --             hybridnumber = false,
        --             winhighlight = false,
        --             cursorline = false,
        --             treewidth = 30,
        --         }
        --     end
        -- }

        -- zettelkasten
        --use {
            --"megalithic/zk.nvim",
            --requires = {
                --'nvim-telescope/telescope.nvim'
            --},
            --config = function()
                --require('zk').setup({
                    --debug = false,
                    --log = true,
                    --default_keymaps = true,
                    --fuzzy_finder = "telescope",
                    --link_format = "markdown"
                --})
                --require('telescope').load_extension('zk')
            --end
        --}

        --use {
            --"oberblastmeister/neuron.nvim",
            --requires = {
            --    'nvim-lua/popup.nvim',
            --    'nvim-lua/plenary.nvim',
            --    'nvim-telescope/telescope.nvim'
            --},
            --config = function()
            --    require'neuron'.setup {
            --        virtual_titles = true,
            --        mappings = false,
            --        run = nil,
            --        neuron_dir = "/platte/Documents/zettelkasten",
            --        leader = "gz",
            --    }
            --end
        --}

        -- ideas:
        -- rust-tools.nvim
        -- extra colors for older colorschemes

        -- vim wiki / pandoc
        -- use {
        --     'vimwiki/vimwiki',
        --     config = function()
        --         -- vimwiki
        --         vim.g.vimwiki_key_mappings = {
        --             global = 0,
        --             links = 0,
        --             html = 0,
        --             mouse = 0,
        --             table_mappings = 0,
        --         }
        --     end
        -- }
    end
}

-- install updates if packer has just been downloaded
if install_packages then
    execute("PackerInstall")
end
