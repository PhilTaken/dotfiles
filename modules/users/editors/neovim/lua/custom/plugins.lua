-- Install packer
--

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

        use {
            'lewis6991/impatient.nvim',
            config = function()
                require('impatient').enable_profile()
            end
        }

        -- add some startuptime hacks / improvements
        use {
            {
                'dstein64/vim-startuptime',
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
                        transparent_background = false,
                        term_colors = true,
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
                    vim.g.catppuccin_flavour = "mocha"
                    vim.cmd[[colorscheme catppuccin]]
                end
            },
            {
                'folke/lsp-colors.nvim',
            }
        }

        -- start menu
        use {
            'goolord/alpha-nvim',
            config = function()
                require'alpha'.setup(require'alpha.themes.startify'.opts)
            end
        }

        use {
            'ludovicchabant/vim-gutentags',
            config = function()
                vim.g.gutentags_file_list_command = 'rg --files'
            end,
            event = "BufRead",
        }

        -- root vim in git dir
        use {
            'zah/vim-rooter',
            config = function()
                vim.g.rooter_targets = '/,*'
                vim.g.rooter_patterns = { '.git/' }
                vim.g.rooter_resolve_links = 1
            end
        }

        -- buffers visible above in a bar
        use {
            'romgrk/barbar.nvim',
            requires = { 'kyazdani42/nvim-web-devicons' },
            event = "BufRead",
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
            },
            -- fancy symbols
            {
                'nvim-telescope/telescope-symbols.nvim',
                after = 'telescope.nvim',
            },
            -- git worktree integration
            {
                'ThePrimeagen/git-worktree.nvim',
                requires = {
                    'nvim-telescope/telescope.nvim',
                },
                config = function()
                    require("telescope").load_extension("git_worktree")
                end,
                after = 'telescope.nvim',
            },
            -- fancy file browser
            {
                'nvim-telescope/telescope-file-browser.nvim',
                requires = {
                    'nvim-telescope/telescope.nvim',
                },
                config = function()
                    require("telescope").load_extension("file_browser")
                end,
                after = "telescope.nvim",
            },
            -- telescope projects
            {
                'nvim-telescope/telescope-project.nvim',
                requires = {
                    'nvim-telescope/telescope.nvim',
                },
                config = function()
                    require("telescope").load_extension("project")
                end,
                after = "telescope.nvim",
            },
            {
                'jvgrootveld/telescope-zoxide',
                requires = {
                    'nvim-lua/popup.nvim',
                    'nvim-lua/plenary.nvim',
                    'nvim-telescope/telescope.nvim',
                },
                config = function()
                    require("telescope").load_extension("zoxide")
                end,
                after = "telescope.nvim",
            }
        }

        -- statusline
        use {
            --'glepnir/galaxyline.nvim',
            'NTBBloodbath/galaxyline.nvim',
            branch = 'main',
            config = function()
                require'custom.statusline'
            end,
            requires = {'kyazdani42/nvim-web-devicons', opt = true},
            event = "BufEnter",
        }

        -- mark specific comments for
        --use {
            --"folke/todo-comments.nvim",
            --requires = "nvim-lua/plenary.nvim",
            --config = function()
                --require("todo-comments").setup{}
            --end
        --}

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
            {
                'neovim/nvim-lspconfig',
                config = function()
                    require('custom.lsp')
                end,
                requires = {
                    "hrsh7th/cmp-nvim-lsp",
                    {
                        'onsails/lspkind-nvim',
                        config = function()
                            require'lspkind'.init()
                        end
                    },
                },
            },
            {
                "jose-elias-alvarez/null-ls.nvim",
                disable = true,
                requires = {
                    "nvim-lua/plenary.nvim",
                    "neovim/nvim-lspconfig",
                },
                config = function()
                    local nls = require("null-ls")
                    local nfmt = nls.builtins.formatting
                    local nca = nls.builtins.code_actions
                    local nd = nls.builtins.diagnostics
                    nls.config({
                        sources = {
                            nfmt.stylua,
                            nfmt.black,
                            --nfmt.fixjson,
                            --nfmt.fnlfmt,
                            nfmt.fprettify,
                            nfmt.format_r,
                            nfmt.nixfmt,
                            nfmt.prettier,
                            --nfmt.rustfmt,

                            nca.gitsigns,

                            --nd.chktex,
                            nd.flake8,
                            nd.luacheck,
                            nd.pylint
                        }
                    })
                    require("lspconfig")['null-ls'].setup({})
                end,
            }
        }

        -- ast-like code parsing utility for hl / indent / lsp
        use {
            'nvim-treesitter/nvim-treesitter',
            run = ":TSUpdate",
            config = function()
                require'nvim-treesitter.configs'.setup {
                    ensure_installed = {
                        "bash", "c", "clojure",
                        "cmake", "comment", "commonlisp",
                        "cpp", "css", "dockerfile", "fennel",
                        "help", "html", "http", "norg",
                        "javascript", "json", "json5",
                        "latex", "ledger", "lua", "make",
                        "nix", "python", "r", "regex",
                        "rst", "ruby", "rust", "toml",
                        "typescript", "vim", "vue", "yaml"
                    },
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
                    config = function()
                        require('custom.snippets')
                    end,
                    requires = { 'rafamadriz/friendly-snippets' },
                },
                { "hrsh7th/cmp-buffer", after = "nvim-cmp"},
                { "hrsh7th/cmp-path", after = "nvim-cmp" },
                { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" },
                { "lukas-reineke/cmp-under-comparator" },
                { 'andersevenrud/cmp-tmux', after = "nvim-cmp" },
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

        -- specific language integrations
        use {
            -- rust-tools.nvim
            {
                'LnL7/vim-nix',
                ft = "nix"
            },
            {
                'bakpakin/fennel.vim',
                ft = "fennel"
            },
            {
                'bakpakin/janet.vim',
                ft = "janet"
            },
            {
                'hylang/vim-hy',
                config = function()
                    vim.g.hy_enable_conceal = 1
                end,
                event = "BufRead",
            },
            {
                'Olical/conjure',
                config = function()
                    vim.cmd[[let g:conjure#filetype#fennel = "conjure.client.fennel.stdio"]]
                end,
                -- lazy-loading on filetypes does not work for some reason
                event = "BufRead",
            },
            {
                'jalvesaq/Nvim-R',
                config = function()
                    local cmd = vim.cmd
                    cmd[[let R_non_r_compl = 0]]
                    cmd[[let R_user_maps_only = 1]]
                    cmd[[let R_csv_app = 'tmux new-window vd']]
                    cmd[[let R_auto_start = 1]]
                end,
                ft = { "r", "rmd" },
            },
            {
                'elkowar/yuck.vim',
            }
        }

        -- extra targets
        use {
            'wellle/targets.vim',
            event = "BufEnter"
        }

        use {
            {
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
            },
            {
                'sindrets/diffview.nvim',
                requires = "nvim-lua/plenary.nvim",
                config = function()
                    require("diffview").setup{}
                end
            }
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
                require('toggleterm').setup{
                    hide_numbers = true,
                    shell = vim.o.shell,
                    size = function(term)
                        if term.direction == "horizontal" then
                            return 15
                        elseif term.direction == "vertical" then
                            return vim.o.columns * 0.4
                        end
                    end,
                }
            end,
            --module = 'toggleterm.terminal',
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
                    enable_persistent_history = true,
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

        use {
            'eraserhd/parinfer-rust',
            cmd = "ParinferOn",
            run = "nix-shell --run \"cargo build --release\"",
        }

        use {
            "nvim-neorg/neorg",
            --ft = "norg",
            after = { "nvim-treesitter" },
            config = function()
                require('neorg').setup {
                    load = {
                        ["core.defaults"] = {}, -- Load all the defaults
                        ["core.gtd.base"] = {
                            config = {
                                workspace = "vault",
                                exclude = { "notes/" }, -- Optional: all excluded files from the workspace are not part of the gtd workflow
                                projects = {
                                    show_completed_projects = false,
                                    show_projects_without_tasks = false,
                                },
                                custom_tag_completion = true,
                            },
                        },
                        ["core.norg.dirman"] = {
                            config = {
                                workspaces = {
                                    vault = "~/Documents/syncthing/vault/",
                                },
                                --autochdir = true,
                                index = "index.norg",
                            },
                        },
                        ["core.presenter"] = {
                            config = {
                                zen_mode = "zen-mode",
                            },
                        },
                        ["core.integrations.treesitter"] = {}, -- Enable the telescope module
                        ["core.integrations.nvim-cmp"] = {},
                        --["core.norg.journal"] = {},
                        --["core.norg.q l.toc"] = {},
                        ["core.norg.concealer"] = {},
                        ["core.integrations.telescope"] = {}, -- Enable the telescope module
                    },
                }
            end,
            requires = {
                "nvim-lua/plenary.nvim",
                {
                    "nvim-neorg/neorg-telescope",
                },
                {
                    "folke/zen-mode.nvim",
                    config = function()
                        require("zen-mode").setup{}
                    end
                }
            };
        }
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