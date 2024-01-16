local Terminal = require("toggleterm.terminal").Terminal

local on_open = function(term)
	vim.cmd("startinsert!")
	vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
end

local M = {}

M.vterm = Terminal:new({
	direction = "vertical",
	on_open = on_open,
	close_on_exit = true,
})

M.hterm = Terminal:new({
	direction = "horizontal",
	on_open = on_open,
	close_on_exit = true,
})

M.bgshell = Terminal:new({
	direction = "float",
	float_opts = {
		border = "double",
	},
	close_on_exit = true,
})

M.bottom = Terminal:new({
	cmd = "btm",
	direction = "float",
	float_opts = {
		border = "double",
	},
	close_on_exit = true,
})

return M
