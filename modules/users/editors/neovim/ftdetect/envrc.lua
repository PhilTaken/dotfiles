vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = ".envrc",
	callback = function()
		vim.bo.filetype = "sh"
	end,
})
