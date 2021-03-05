local g = vim.g
local cmd = vim.cmd

--- global options
g.rooter_targets = '/,*'
g.rooter_patterns = { '.git/' }
g.rooter_resolve_links = 1

g.pear_tree_smart_closers = 1
g.pear_tree_smart_openers = 1
g.pear_tree_smart_backspace = 1

g.tmux_navigator_no_mappings = 1
g.tmux_navigator_save_on_switch = 1

-- echodoc
cmd[[let g:echodoc#enable_at_startup = 1]]
cmd[[let g:echodoc#type = 'floating']]

-- float-preview.nvim
-- dock the preview window
cmd[[let g:float_preview#docked = 1]]

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

-- lexima
g.lexima_no_default_rules = true
vim.fn['lexima#set_default_rules']()

-- vimwiki
g.vimwiki_key_mappings = {
    global = 0,
    links = 0,
    html = 0,
    mouse = 0,
    table_mappings = 0,
}

-- fireenv
g.firenvim_config = {
    localSettings = {
        ['.*'] = {
            cmdline = 'firenvim',
            priority = 0,
            takeover = "always",
        }
    }
}

require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
        path = true;
        buffer = true;
        calc = true;
        nvim_lsp = true;
        nvim_lua = true;
        tags = true;
        snippets_nvim = true;
        treesitter = true;
    };
}


-- snippets
require'snippets'.use_suggested_mappings()
local snippets = require 'snippets'
local U = require'snippets.utils'

snippets.snippets = {
    _global =  {
        copyright = U.force_comment [[Copyright (C) Philipp Herzog ${=os.date("%Y")}]];
    };
    lua = {
        req = [[local ${2:${1|S.v:match"([^.()]+)[()]*$"}} = require '$1']];
        func = [[function${1|vim.trim(S.v):gsub("^%S"," %0")}(${2|vim.trim(S.v)})$0 end]];
        ["local"] = [[local ${2:${1|S.v:match"([^.()]+)[()]*$"}} = ${1}]];
        ["for"] = U.match_indentation [[
        for ${1:i}, ${2:v} in ipairs(${3:t}) do
            $0
        end]];
    };
}

-- blankline
g.indentLine_char = "┊"
g.indentLine_use_treesitter = true
g.indentLine_fileTypeExclude = { 'help', 'startify', 'packer' }
g.indentLine_bufTypeExclude = { 'terminal', 'nofile' }
--g.indentLine_char_highlight = 'LineNr'
