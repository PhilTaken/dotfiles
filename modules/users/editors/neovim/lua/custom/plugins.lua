-- Install packer
--
-- Only required if you have packer in your `opt` pack
vim.cmd [[packadd packer.nvim]]

require("packer").init {
	auto_reload_compiled = true
}

require('ufo').setup()
require("hotpot").setup({ })
require("stabilize").setup()
require('impatient').enable_profile()
require("telescope").load_extension("git_worktree")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("zoxide")
require('alpha').setup(require'alpha.themes.startify'.opts)
require('colorizer').setup()
require('neoscroll').setup({ hide_cursor = false })
require("gitlinker").setup{ mappings = nil }
require('gitsigns').setup {}
require("diffview").setup{}
require('which-key').setup{}
require('trouble').setup{}
require("Navigator").setup({ auto_save = 'all', disable_on_zoom = true, })
require('nvim-tree').setup { }
require('neoclip').setup{ enable_persistent_history = true, }
require("cybu").setup({ display_time = 350, })

require("indent_blankline").setup {
    buftype_exclude = { "help", "terminal", "nofile", "nowrite" },
    filetype_exclude = { "startify", "dashboard", "man" },
    show_current_context_start = true,
    use_treesitter = true
}

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

-- https://github.com/kevinhwang91/nvim-ufo#customize-fold-text
require('lsp_signature').setup({
    bind = true,
    handler_opts = {
        border = "single"
    },
})

require("lsp_lines").setup()
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = {
        only_current_line = true
    }
})

require'lspkind'.init()

-- colorscheme ^-^
local catppuccin = require('catppuccin')
catppuccin.setup{
    transparent_background = false,
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
}
vim.g.catppuccin_flavour = "mocha"
vim.cmd[[colorscheme catppuccin]]

vim.g.gutentags_file_list_command = 'rg --files'

vim.g.rooter_targets = '/,*'
vim.g.rooter_patterns = { '.git/' }
vim.g.rooter_resolve_links = 1

vim.g.pear_tree_smart_openers = 1
vim.g.pear_tree_smart_closers = 1
vim.g.pear_tree_smart_backspace = 1
vim.g.pear_tree_map_special_keys = 0
vim.g.pear_tree_ft_disabled = { 'TelescopePrompt', 'nofile', 'terminal' }

vim.g.hy_enable_conceal = 1

vim.cmd[[let g:echodoc#enable_at_startup = 1]]
vim.cmd[[let g:echodoc#type = 'floating']]

vim.cmd[[let g:float_preview#docked = 1]]

vim.cmd[[let g:conjure#filetype#fennel = "conjure.client.fennel.stdio"]]

vim.cmd[[let g:pandoc#spell#enabled = 0]]

vim.notify = require("notify")

-- #####################################

require('packer').startup{
    compile_path = vim.fn.stdpath('config')..'/lua/packer_compiled.lua',
    function(use)
        use {
            'eraserhd/parinfer-rust',
            cmd = "ParinferOn",
            run = "nix-shell --run \"cargo build --release\"",
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
