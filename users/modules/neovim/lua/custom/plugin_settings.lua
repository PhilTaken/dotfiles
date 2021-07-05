local g = vim.g
local cmd = vim.cmd
local saga = require 'lspsaga'

-- telescope
require('custom.tele_init')

-- compe
require('custom.compe')

-- snippets
--require('custom.snippets')

--- global options
g.rooter_targets = '/,*'
g.rooter_patterns = { '.git/' }
g.rooter_resolve_links = 1

-- tmux navigator
g.tmux_navigator_no_mappings = 1
g.tmux_navigator_save_on_switch = 1

-- pandoc
cmd[[let g:pandoc#spell#enabled = 0]]

-- echodoc
cmd[[let g:echodoc#enable_at_startup = 1]]
cmd[[let g:echodoc#type = 'floating']]

-- float-preview.nvim
-- dock the preview window
cmd[[let g:float_preview#docked = 1]]

-- extra icon for the completer (compe)
require'lspkind'.init{}

-- setup treesitter
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "json", "html", "toml",
        "bash", "css", "yaml",
	"rust", "cpp", -- "julia",
	"python"
    },
    highlight = {
        enable = true,
    },
}

-- gitsigns
require('gitsigns').setup {
    signs = {
        add          = {hl = 'GitGutterAdd'   , text = '+'},
        change       = {hl = 'GitGutterChange', text = '~'},
        delete       = {hl = 'GitGutterDelete', text = '_'},
        topdelete    = {hl = 'GitGutterDelete', text = '‾'},
        changedelete = {hl = 'GitGutterChange', text = '~'},
    }
}

-- pear tree
g.pear_tree_smart_openers = 1
g.pear_tree_smart_closers = 1
g.pear_tree_smart_backspace = 1
g.pear_tree_map_special_keys = 0
g.pear_tree_ft_disabled = { 'TelescopePrompt', 'nofile', 'terminal' }

-- vimwiki
g.vimwiki_key_mappings = {
    global = 0,
    links = 0,
    html = 0,
    mouse = 0,
    table_mappings = 0,
}

g.jupyter_ascending_match_pattern = ".py"

cmd[[let R_non_r_compl = 0]]
cmd[[let R_user_maps_only = 1]]
cmd[[let R_csv_app = 'tmux new-window vd']]
cmd[[let R_auto_start = 1]]


saga.init_lsp_saga()
