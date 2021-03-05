-- Install packer
local execute = vim.api.nvim_command
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
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
    --use 'airblade/vim-gitgutter'
    use {
        'lewis6991/gitsigns.nvim',
        requires = {
            'nvim-lua/plenary.nvim'
        }
    }

    -- change pwd to git root
    use 'zah/vim-rooter'

    -- start menu
    use 'mhinz/vim-startify'

    -- manage surrounds e.g. quotation marks, html tags, ...
    use 'tpope/vim-surround'

    -- increment/decrement dates
    --use 'tpope/vim-speeddating'

    -- extra targets
    use 'wellle/targets.vim'

    -- show function arguments
    --use 'Shougo/echodoc.vim'

    -- commenting
    use 'preservim/nerdcommenter'

    -- auto end quotation mark/bracket
    --use 'jiangmiao/auto-pairs'
    use 'cohama/lexima.vim'

    -- tmux movements, in splits
    use 'christoomey/vim-tmux-navigator'

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
    use 'ayu-theme/ayu-vim'

    -- vim wiki
    use 'vimwiki/vimwiki'

    -- pandoc
    use 'vim-pandoc/vim-pandoc'
    use 'vim-pandoc/vim-pandoc-syntax'

    -- config for the builtin language server
    use 'neovim/nvim-lspconfig'

    -- repeat more motions
    use 'tpope/vim-repeat'

    --switch between single and multiline
    use 'AndrewRadev/splitjoin.vim'

    -- ultisnips alternative in lua
    use 'norcalli/snippets.nvim'

    -- blankline indent help
    use { 'lukas-reineke/indent-blankline.nvim', branch="lua" }
    --use 'Yggdroot/indentLine'

    -- nvim integration for firefox
    use {
        'glacambre/firenvim',
        run = function() vim.fn['firenvim#install'](0) end,
    }

    -- treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ":TSUpdate",
    }

    -- completion manager
    use 'hrsh7th/nvim-compe'

    -- completion with docked floating windows
    use 'ncm2/float-preview.nvim'

    -- nix
    use 'LnL7/vim-nix'

    -- floaterm
    use 'voldikss/vim-floaterm'
end)


-- setup treesitter
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "json", "html", "toml",
        "bash", "css", "yaml"
    },
    highlight = {
        enable = true,
    },
}
