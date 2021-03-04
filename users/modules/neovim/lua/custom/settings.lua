local g = vim.g
local o = vim.o
local wo = vim.wo
local bo = vim.bo

-- leader
g.mapleader = ' '

-- global options
o.wildignore = "*.swp,*.bak,*.pyc,*.class"
o.pumblend = 20
o.mouse = "a"
o.inccommand = "split"
o.backup = false
o.swapfile = false
o.writebackup = false
o.spell = false
o.completeopt = "menuone,noinsert,noselect"
o.shortmess = "filnxtToOFc"
o.cmdheight = 1
o.updatetime = 300
o.autowrite = true
o.hidden = true

o.ignorecase = true
o.smartcase = true

o.incsearch = true
o.hlsearch = true

o.backspace = "indent,eol,start"

o.shiftround = true
o.timeoutlen = 300
o.ttimeoutlen = 0


o.number = true
o.relativenumber = true
o.laststatus = 2

bo.formatoptions = "tcqj"
bo.tabstop = 4
bo.shiftwidth = 4
bo.expandtab = true
bo.copyindent = true

wo.signcolumn = "yes"


--- global options
g.rooter_targets = '/,*'
g.rooter_patterns = { '.git/' }
g.rooter_resolve_links = 1

g.NERDDefaultAlign = "left"
g.NERDToggleCheckAllLines = 1
g.UltiSnipsExpandTrigger = "JJ"
g.UltiSnipsJumpForwardTrigger = "<c-j>"
g.UltiSnipsJumpBackwardTrigger = "<c-k>"
g.UltiSnipsEditSplit = "horizontal"
g.pear_tree_smart_closers = 1
g.pear_tree_smart_openers = 1
g.pear_tree_smart_backspace = 1

g.tmux_navigator_no_mappings = 1
g.tmux_navigator_save_on_switch = 1


g.completion_enable_snippet = "UltiSnips"
g.completion_chain_complete_list = {
    { complete_items = { 'lsp', 'snippet', 'path' } },
    { complete_items = { 'ts', 'buffers' } },
}
g.completion_auto_change_source = 1

