local o = vim.o
local wo = vim.wo
local bo = vim.bo

-- leader, for mappings
vim.g.mapleader = ' '

-- ignore these in searches
o.wildignore = "*.swp,*.bak,*.pyc,*.class"

o.cmdheight = 2

o.termguicolors = true
vim.g.ayucolor = "mirage"
vim.cmd[[colorscheme ayu]]

-- popup menu opacity
o.pumblend = 20

-- enable mouse
o.mouse = "a"

-- show changes incrementally
o.inccommand = "nosplit"

-- no backup/swapfiles
o.backup = false
o.swapfile = false
o.writebackup = false

-- write to undofile in undodir
vim.cmd[[set undodir=$XDG_DATA_HOME/nvim/undodir]]
vim.cmd[[set undofile]]

-- disable spellchecking
o.spell = false

-- improved completers
o.completeopt = "menuone,noinsert,noselect"
o.shortmess = "filnxtToOFc"

-- timeout for cursorhold  autocommand event
o.updatetime = 300

-- do not save when switching buffers
o.hidden = true

-- improved search
o.ignorecase = true
o.smartcase = true

-- highlight on search
o.hlsearch = false
o.incsearch = true

-- backspace on start of line
o.backspace = "indent,eol,start"

o.shiftround = true
o.timeoutlen = 300
o.ttimeoutlen = 0

o.laststatus = 2
bo.formatoptions = "tcqj"

-- tab width, expand to spaces
bo.tabstop = 4
bo.shiftwidth = 4
bo.expandtab = true

-- same indent on new lines
bo.copyindent = true

-- line numbers
wo.number = true
wo.relativenumber = true
wo.signcolumn = "yes"
