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
vim.api.nvim_exec([[
augroup Packer
autocmd!
autocmd BufWritePost plugins.lua PackerCompile
augroup end
]], false)

local use = require('packer').use
require('packer').startup(function()
    -- pack packer
    use {'wbthomason/packer.nvim', opt = true}

    -- git signs in signcolumn
    use {
        'lewis6991/gitsigns.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        tag = 'v0.2',
    }

    -- change pwd to git root
    use 'zah/vim-rooter'

    -- start menu
    use 'mhinz/vim-startify'

    -- commenting
    use 'preservim/nerdcommenter'

    -- auto end quotation mark/bracket
    --use 'cohama/lexima.vim'
    use 'tmsvg/pear-tree'
    -- use 'jiangmao/auto-pairs'
    -- specifically https://github.com/jiangmiao/auto-pairs/blob/master/plugin/auto-pairs.vim

    -- show function arguments
    use 'Shougo/echodoc.vim'

    -- telescope
    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
    }

    -- statusline
    use {
        'glepnir/galaxyline.nvim',
        branch = 'main',
        config = function() require'custom.statusline' end,
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }

    -- ayu color scheme
    use {
        'ayu-theme/ayu-vim',
        config = function()
            vim.g.ayucolor = "mirage"
            vim.cmd[[colorscheme ayu]]
        end
    }

    -- extra colors for older colorschemes
    use 'folke/lsp-colors.nvim'

    --use {
        --'Pocco81/Catppuccino.nvim',
        --config = function()
            --local catppuccino = require('catppuccino')
            --catppuccino.setup{
                --colorscheme = "soft_manilo",
                --integrations = {
                    --lsp_saga = true,
                    --gitsigns = true,
                    --telescope = true,
                    --which_key = true,
                --},
            --}
            --catppuccino.load()
        --end
    --}

    -- vim wiki / pandoc
    --use 'vimwiki/vimwiki'
    use 'vim-pandoc/vim-pandoc'
    use 'vim-pandoc/vim-pandoc-syntax'

    -- ultisnips alternative in lua
    --use 'norcalli/snippets.nvim'

    -- config for the builtin language server
    use 'neovim/nvim-lspconfig'

    -- lspsaga
    use 'glepnir/lspsaga.nvim'

    -- signature help
    use {
        "ray-x/lsp_signature.nvim",
    }

    -- treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ":TSUpdate",
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
            { 'andersevenrud/compe-tmux', branch = 'cmp' },

            "L3MON4D3/LuaSnip",
            'saadparwaiz1/cmp_luasnip'
        }
    }

    -- direnv sourcing in nvim
    use "direnv/direnv.vim"

    -- shareable git links
    use {
        'ruifm/gitlinker.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function() require("gitlinker").setup{ mappings = nil } end,
    }

    -- completion with docked floating windows
    use 'ncm2/float-preview.nvim'

    -- nix
    use 'LnL7/vim-nix'

    -- extra targets
    use 'wellle/targets.vim'

    -- extra icons for completion
    use 'onsails/lspkind-nvim'

    -- manage surrounds e.g. quotation marks, html tags, ...
    use 'tpope/vim-surround'

    -- highlighting for the glsl (gl shader language)
    use 'tikhomirov/vim-glsl'

    --switch between single and multiline
    --use 'AndrewRadev/splitjoin.vim'

    use 'jalvesaq/Nvim-R'

    -- zettelkasten
    --use { "megalithic/zk.nvim" }
    use {
        "oberblastmeister/neuron.nvim",
        requires = {
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim'
        },
    }

    -- show keybinds + comment for them
    use {
        "folke/which-key.nvim",
        config = function() require'which-key'.setup{} end,
    }

    -- quick peek to certain line numbers
    use {
        'nacro90/numb.nvim',
        config = function() require('numb').setup() end,
    }

    use {
        'folke/trouble.nvim',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function() require('trouble').setup{} end,
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
    use 'hkupty/iron.nvim'

    -- lazygit
    --use {
        --'kdheepak/lazygit.nvim',
        --requires = 'nvim-lua/plenary.nvim'
    --}

    use {
        "akinsho/toggleterm.nvim",
        config = function()
            require('toggleterm').setup{}
        end
    }

    use {
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function() require'nvim-tree'.setup {
            auto_close = true,
        } end
    }

    --use {
        --'aserowy/tmux.nvim',
        --config = function()
            --require("tmux").setup({

            --})
        --end
    --}
    --- ideas:
    -- rust-tools.nvim
end)

-- install updates if packer has just been downloaded
if install_packages then
    execute("PackerInstall")
end
