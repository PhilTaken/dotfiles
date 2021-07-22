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
        requires = { 'nvim-lua/plenary.nvim' }
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
    use 'ayu-theme/ayu-vim'

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

    -- completion manager
    use 'hrsh7th/nvim-compe'

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

    -- julia lang
    --use 'JuliaEditorSupport/julia-vim'

    -- highlighting for the glsl (gl shader language)
    use 'tikhomirov/vim-glsl'

    -- interop with jupyter notebooks
    use 'untitled-ai/jupyter_ascending.vim'

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

    --- ideas:
    -- nvim-r
    -- rust-tools.nvim
end)

-- install updates if packer has just been downloaded
if install_packages then
	execute("PackerInstall")
end
