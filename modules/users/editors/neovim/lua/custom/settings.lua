local o = vim.o
--local wo = vim.wo
--local bo = vim.bo
local opt = vim.opt

-- leader, for mappings
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.tex_flavor = "latex"
vim.g.loaded_perl_provider = 0

-- ignore these in searches
opt.wildignore = { "*.swp", "*.bak", "*.pyc", "*.class" }
opt.wildmode = { "list", "longest" }

opt.isfname:append("@-@")

-- scrolloff
opt.scrolloff = 8

opt.langremap = true

o.cmdheight = 1

-- single statusline at the bottom
o.laststatus = 3

-- dont show the mode in the last line, have a status line for that
o.showmode = false

o.clipboard = 'unnamedplus'
o.breakindent = true

-- show path to file above buffer
--o.winbar = "%f"
o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

-- folds
--o.foldmethod = "syntax"
--o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
o.foldcolumn = "1" -- 'auto:1'
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true

opt.termguicolors = true

-- popup menu opacity
opt.pumblend = 20

-- enable mouse
opt.mouse = "a"

-- guifont for neovide
opt.guifont = "Hack Nerd Font,Iosevka Comfy:h19"

-- no folds pls
opt.foldenable = false

-- show changes incrementally
opt.inccommand = "split"

opt.cursorline = true

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
o.updatetime = 250
o.timeoutlen = 300

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
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- backspace on start of line
opt.backspace = { "indent", "eol", "start" }

opt.shiftround = true

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

vim.loader.enable()

-- improved quickfix aesthetics

local fn = vim.fn

function _G.qftf(info)
	local items
	local ret = {}
	-- The name of item in list is based on the directory of quickfix window.
	-- Change the directory for quickfix window make the name of item shorter.
	-- It's a good opportunity to change current directory in quickfixtextfunc :)
	--
	-- local alterBufnr = fn.bufname('#') -- alternative buffer is the buffer before enter qf window
	-- local root = getRootByAlterBufnr(alterBufnr)
	-- vim.cmd(('noa lcd %s'):format(fn.fnameescape(root)))
	--
	if info.quickfix == 1 then
		items = fn.getqflist({ id = info.id, items = 0 }).items
	else
		items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
	end
	local limit = 31
	local fnameFmt1, fnameFmt2 = "%-" .. limit .. "s", "…%." .. (limit - 1) .. "s"
	local validFmt = "%s │%5d:%-3d│%s %s"
	for i = info.start_idx, info.end_idx do
		local e = items[i]
		local fname = ""
		local str
		if e.valid == 1 then
			if e.bufnr > 0 then
				fname = fn.bufname(e.bufnr)
				if fname == "" then
					fname = "[No Name]"
				else
					fname = fname:gsub("^" .. vim.env.HOME, "~")
				end
				-- char in fname may occur more than 1 width, ignore this issue in order to keep performance
				if #fname <= limit then
					fname = fnameFmt1:format(fname)
				else
					fname = fnameFmt2:format(fname:sub(1 - limit))
				end
			end
			local lnum = e.lnum > 99999 and -1 or e.lnum
			local col = e.col > 999 and -1 or e.col
			local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()
			str = validFmt:format(fname, lnum, col, qtype, e.text)
		else
			str = e.text
		end
		table.insert(ret, str)
	end
	return ret
end

vim.o.qftf = "{info -> v:lua._G.qftf(info)}"


vim.filetype.add({
	extension = {
		hurl = "hurl",
	}
})
