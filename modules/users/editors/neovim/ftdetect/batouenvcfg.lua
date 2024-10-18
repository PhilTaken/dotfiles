vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "environment.cfg",
	callback = function()
		vim.bo.filetype = "ini"
	end,
})
