local o = vim.o
--local wo = vim.wo
--local bo = vim.bo
local opt = vim.opt

-- leader, for mappings
vim.g.mapleader = ' '
vim.g.maplocalleader = ","
vim.g.tex_flavor = 'latex'
vim.g.loaded_perl_provider = 0

-- ignore these in searches
opt.wildignore = { "*.swp", "*.bak", "*.pyc", "*.class" }
opt.wildmode = { 'list', 'longest' }

opt.langremap = true

o.cmdheight = 2

-- dont show the mode in the last line, have a status line for that
o.showmode = false

opt.termguicolors = true

-- popup menu opacity
opt.pumblend = 20

-- enable mouse
opt.mouse = "a"

-- no folds pls
opt.foldenable = false

-- show changes incrementally
opt.inccommand = "nosplit"

-- no backup/swapfiles
opt.backup = false
opt.swapfile = false
opt.writebackup = false


-- write to undofile in undodir
--vim.cmd[[set undodir=$XDG_DATA_HOME/nvim/undodir]]
--vim.cmd[[set undofile]]

--vim.cmd[[let R_external_term = 1]]

-- disable spellchecking
opt.spell = false

-- improved completers
opt.completeopt = { "menuone", "noinsert", "noselect" }
opt.shortmess = "filnxtToOFc"

-- timeout for cursorhold  autocommand event
--o.updatetime = 300

-- do not save when switching buffers
opt.hidden = true

-- improved search
opt.ignorecase = true
opt.smartcase = true
opt.smartindent = true

-- highlight on search
opt.hlsearch = false
opt.incsearch = true
opt.list = true

-- backspace on start of line
opt.backspace = { "indent", "eol", "start" }

opt.shiftround = true
--o.timeoutlen = 300
--o.ttimeout = true
--o.ttimeoutlen = 0

--o.laststatus = 2
--opt.formatoptions = "tcqj"

-- tab width, expand to spaces
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- same indent on new lines
opt.copyindent = true

-- line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "auto"

opt.wrap = false

vim.diagnostic.config({
    underline = false,
    virtual_test = true,
    signs = true,
    severity_sort = true,
})
