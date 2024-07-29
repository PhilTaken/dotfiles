-- autocommands
-- dont save passwords in swapfile...
vim.cmd([[au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup]])

-- highlight yanks
vim.cmd([[au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }]])

-- disable line numbers in terminal
vim.cmd([[au TermOpen * setlocal norelativenumber nonumber]])

-- strip trailing whitespaces
vim.cmd([[au FileType c,cpp,python,rust,nix,lua,ruby,r autocmd BufWritePre <buffer> :%s/\s\+$//e]])

-- create non-exist files under cursor
vim.cmd([[map gf :e <cfile><CR>]])

-- TODO: attempt to autostart netrep when detecting janet
-- TODO: package spork/netrepl using nix, provide it via overlay
vim.cmd([[au BufEnter *.fnl,*.rkt,*.hy,*.scm,*.janet,*.py :lua which_key_conjure()]])

-- terminals
local terms = require("custom.terminals")
local diffview = require("diffview")
local wk = require("which-key")

local function visual_selection_range()
	-- https://github.com/neovim/neovim/pull/13896#issuecomment-774680224
	--local csrow = vim.api.nvim_buf_get_mark(0, "<")[1]
	--local cerow = vim.api.nvim_buf_get_mark(0, ">")[1]
	local csrow = vim.fn.getpos("v")[2]
	local cerow = vim.api.nvim_win_get_cursor(0)[1]
	if csrow <= cerow then
		return { csrow, cerow }
	else
		return { cerow, csrow }
	end
end

if vim.g.neovide == true then
	wk.add({
		{
			"<C-=>",
			function()
				vim.g.neovide_scale_factor = math.min(vim.g.neovide_scale_factor + 0.1, 2.0)
			end,
		},
		{
			"<C-->",
			function()
				vim.g.neovide_scale_factor = math.max(vim.g.neovide_scale_factor - 0.1, 0.1)
			end,
		},
		{
			"<C-+>",
			function()
				vim.g.neovide_transparency = math.min(vim.g.neovide_transparency + 0.05, 2.0)
			end,
		},
		{
			"<C-_>",
			function()
				vim.g.neovide_transparency = math.max(vim.g.neovide_transparency - 0.05, 0.1)
			end,
		},
		{
			"<C-0>",
			function()
				vim.g.neovide_scale_factor = 0.5
			end,
		},
		{
			"<C-)>",
			function()
				vim.g.neovide_transparency = 0.9
			end,
		},
	})
end

--------------
-- MAPPINGS --
--------------

wk.add({
	{
		";",
		function()
			require("custom.tele").buffers()
		end,
		desc = "Buffers",
	},
	{ "<A-a>", "<C-a>", desc = "Increment Number" },
	{ "<A-x>", "<C-x>", desc = "Decrement Number" },
	{ "<C-c>", "<cmd>cprev<cr>zz", desc = "go to previous entry in quickfix" },
	{ "<C-l>", "<cmd>cnext<cr>zz", desc = "go to next entry in quickfix" },
	{ "<F2>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle nvimtree" },
	{ "<c-s-tab>", "<Plug>(CybuLastusedPrev)", desc = "Previous Buffer" },
	{ "<c-tab>", "<Plug>(CybuLastusedNext)", desc = "Next Buffer" },
	{ "<leader><leader>", "<cmd>noh<CR>", desc = "Disable Highlighting" },

	{ "<leader>d", group = "diffview" },
	{
		"<leader>dc",
		function()
			diffview.close()
		end,
		desc = "Close Diffview",
	},
	{
		"<leader>df",
		function()
			diffview.file_history(nil, "%")
		end,
		desc = "Diffview File History",
	},
	{
		"<leader>dh",
		function()
			diffview.file_history()
		end,
		desc = "Diffview History",
	},
	{
		"<leader>do",
		function()
			diffview.open()
		end,
		desc = "Open Diffview",
	},

	{ "<leader>f", group = "find" },
	{
		"<leader>fb",
		function()
			require("custom.tele").extensions.file_browser.file_browser()
		end,
		desc = "Telescope file browser",
	},
	{
		"<leader>ff",
		function()
			require("custom.tele").find_files()
		end,
		desc = "Find Files in current dir",
	},
	{
		"<leader>fg",
		function()
			require("custom.tele").live_grep()
		end,
		desc = "Live Grep in current dir",
	},
	{
		"<leader>fp",
		function()
			require("custom.tele").git_workspace()
		end,
		desc = "Telescope git workspace browser into find_files",
	},
	{
		"<leader>fs",
		function()
			require("custom.tele").treesitter()
		end,
		desc = "Treesitter Symbols",
	},
	{
		"<leader>ft",
		function()
			require("custom.tele").tags()
		end,
		desc = "Browse workspace tags",
	},
	{
		"<leader>fy",
		function()
			require("custom.tele").extensions.neoclip.default()
		end,
		desc = "Manage yank register",
	},

	{ "<leader>g", group = "git" },
	{
		"<leader>gY",
		function()
			require("gitlinker").get_repo_url()
		end,
		desc = "copy homepage url to clipboard",
	},
	{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Open git blame" },
	{
		"<leader>gg",
		function()
			require("neogit").open()
		end,
		desc = "Open NeoGit",
	},

	{
		"<leader>go",
		function()
			require("gitlinker").get_buf_range_url(
				"n",
				{ action_callback = require("gitlinker.actions").open_in_browser }
			)
		end,
		desc = "open current buffer's remote in browser",
	},
	{
		"<leader>gy",
		function()
			require("gitlinker").get_buf_range_url("n")
		end,
		desc = "copy link to file in remote to clipboard",
	},
	{ "<leader>r", "<cmd>Rooter<cr>", desc = "Root vim" },

	{ "<leader>s", group = "shells" },
	{
		"<leader>sf",
		function()
			terms["bgshell"]:toggle()
		end,
		desc = "Toggle random shell",
	},
	{
		"<leader>sh",
		function()
			terms["vterm"]:toggle()
		end,
		desc = "Toggle side shell (vertical split)",
	},
	{
		"<leader>st",
		function()
			terms["bottom"]:toggle()
		end,
		desc = "Toggle bottom resource monitor",
	},
	{
		"<leader>sv",
		function()
			terms["vterm"]:toggle()
		end,
		desc = "Toggle side shell (horizontal split)",
	},

	{ "<leader>t", group = "trouble" },
	{ "<leader>ta", "<cmd>TodoTelescope<cr>", desc = "Open TODOs in Telescope" },
	{ "<leader>td", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", desc = "Document Diagnostics" },
	{ "<leader>tl", "<cmd>TroubleToggle loclist<cr>", desc = "Loclist" },
	{ "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List" },
	{ "<leader>tr", "<cmd>TroubleToggle lsp_references<cr>", desc = "Lsp Refrences" },
	{ "<leader>tt", "<cmd>TroubleToggle<cr>", desc = "Toggle trouble" },
	{ "<leader>tw", "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },

	{ "<leader>w", group = "wiki -> neorg" },
	{ "<leader>wc", "<cmd>Neorg return<cr>", desc = "Close Neorg" },
	{ "<leader>wo", "<cmd>Neorg<cr>", desc = "Open Neorg" },
	{
		"<leader>z",
		function()
			require("custom.tele").extensions.zoxide.list()
		end,
		desc = "list zoxide dirs",
	},
	{ "<s-tab>", "<Plug>(CybuPrev)", desc = "Previous Buffer" },
	{ "<tab>", "<Plug>(CybuNext)", desc = "Next Buffer" },

	{
		"gD",
		function()
			vim.lsp.buf.declaration()
		end,
		desc = "go to declaration",
	},
	{
		"gI",
		function()
			require("telescope.builtin").lsp_implementations()
		end,
		desc = "go to implementations",
	},
	{
		"gd",
		function()
			require("telescope.builtin").lsp_definitions()
		end,
		desc = "go to definition",
	},
	{
		"gr",
		function()
			require("telescope.builtin").lsp_references()
		end,
		desc = "go to references",
	},

	{
		"zM",
		function()
			require("ufo").closeAllFolds()
		end,
		desc = "Close all folds",
	},
	{
		"zR",
		function()
			require("ufo").openAllFolds()
		end,
		desc = "Open all folds",
	},
	{
		"zm",
		function()
			require("ufo").closeFoldsWith()
		end,
		desc = "Fold more",
	},
	{
		"zr",
		function()
			require("ufo").openFoldsExceptKinds()
		end,
		desc = "Fold less",
	},

	{
		mode = { "v" },
		{ "/", 'y/<C-R>"<CR>', desc = "Search using visual mode" },
		{ "<leader>d", group = "diffview" },
		{
			"<leader>dh",
			function()
				local range = visual_selection_range()
				vim.pretty_print(vim.inspect(range))
				diffview.file_history(range)
			end,
			desc = "Diffview file history",
		},
		{ "<leader>r", group = "R" },
		{ "<leader>rs", "<Plug>RSendSelection", desc = "Send visual selection" },
	},

	{ ";;", "\28\14", desc = "Escape from terminal mode", mode = "t" },
})

-- register all settings

-- filetype-specific mappings
_G.which_key_conjure = function()
	wk.add({
		{ "<localleader>l", group = "log" },
		{ "<localleader>ls", desc = "open in horizontal split" },
		{ "<localleader>lv", desc = "open in vertical split" },
		{ "<localleader>lt", desc = "open in new tab" },
		{ "<localleader>lq", desc = "close all logs" },
		{ "<localleader>lr", desc = "soft reset" },
		{ "<localleader>lR", desc = "hard reset" },

		{ "<localleader>e", group = "evaluate" },

		{ "<localleader>ee", desc = "form" },
		{ "<localleader>ece", desc = "form, comment" },

		{ "<localleader>er", desc = "root" },
		{ "<localleader>ecr", desc = "root, comment" },

		{ "<localleader>ew", desc = "word" },
		{ "<localleader>ecw", desc = "word, comment" },

		{ "<localleader>e!", desc = "form, replace" },

		{ "<localleader>ef", desc = "file from disk" },
		{ "<localleader>eb", desc = "buffer" },

		{
			mode = "v",
			{ "<localleader>E", desc = "evaluate current selection" },
		},
	})
end

_G.which_key_lsp = function()
	wk.add({
		{
			buffer = 0,

			{
				"<leader>gd",
				function()
					vim.lsp.buf.definition()
				end,
				desc = "Go to definition",
			},
			{
				"<leader>K",
				function()
					vim.lsp.buf.hover()
				end,
				desc = "Show tooltips/docs",
			},

			{
				"[d",
				function()
					vim.diagnostic.goto_next()
				end,
				desc = "Go to next diagnostic",
			},
			{
				"]d",
				function()
					vim.diagnostic.goto_prev()
				end,
				desc = "Go to previous diagnostic",
			},
			{
				"<leader>vws",
				function()
					vim.lsp.buf.workspace_symbol()
				end,
				desc = "View Workspace Symbols",
			},
			{
				"<leader>vd",
				function()
					vim.diagnostic.open_float()
				end,
				desc = "Open float diagnostics",
			},
			{
				"<leader>vca",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "Open code actions",
			},
			{
				"<leader>vrr",
				function()
					vim.lsp.buf.references()
				end,
				desc = "Open references",
			},
			{
				"<leader>vrn",
				function()
					vim.lsp.buf.rename()
				end,
				desc = "Rename",
			},
		},
	})
end
