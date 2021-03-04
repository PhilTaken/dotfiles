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

    use 'tpope/vim-fugitive'
    use 'tpope/vim-dispatch'
    use 'tpope/vim-repeat'
    use 'tpope/vim-sleuth'
    use 'AndrewRadev/splitjoin.vim'
    use 'norcalli/snippets.nvim'
    use { 'lukas-reineke/indent-blankline.nvim', branch="lua" }

    -- nvim integration for firefox
    use {
        'glacambre/firenvim',
        run = ":call firenvim#install(0)"
    }

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

    -- tmux movements, in splits
    use 'christoomey/vim-tmux-navigator'

    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-compe'
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
