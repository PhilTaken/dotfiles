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

-- terminals
--local toggleterm = require("toggleterm")
local terms = require("custom.terminals")
local diffview = require("diffview")

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
	vim.api.nvim_set_keymap(
		"n",
		"<C-=>",
		":lua vim.g.neovide_scale_factor = math.min(vim.g.neovide_scale_factor + 0.1,  2.0)<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<C-->",
		":lua vim.g.neovide_scale_factor = math.max(vim.g.neovide_scale_factor - 0.1,  0.1)<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<C-+>",
		":lua vim.g.neovide_transparency = math.min(vim.g.neovide_transparency + 0.05, 2.0)<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<C-_>",
		":lua vim.g.neovide_transparency = math.max(vim.g.neovide_transparency - 0.05, 0.1)<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 0.5<CR>", { silent = true })
	vim.api.nvim_set_keymap("n", "<C-)>", ":lua vim.g.neovide_transparency = 0.9<CR>", { silent = true })
end

--------------
-- MAPPINGS --
--------------

-- normal mode mappings (global)
local leadern = {
	["<F2>"] = { "<cmd>NvimTreeToggle<cr>", "Toggle nvimtree" },
	["<A-a>"] = { "<C-a>", "Increment Number" },
	["<A-x>"] = { "<C-x>", "Decrement Number" },

	["<c-tab>"] = { "<Plug>(CybuLastusedNext)", "Next Buffer" },
	["<c-s-tab>"] = { "<Plug>(CybuLastusedPrev)", "Previous Buffer" },
	["<tab>"] = { "<Plug>(CybuNext)", "Next Buffer" },
	["<s-tab>"] = { "<Plug>(CybuPrev)", "Previous Buffer" },

	[";"] = {
		function()
			require("custom.tele").buffers()
		end,
		"Buffers",
	},

	g = {
		r = {
			function()
				require("telescope.builtin").lsp_references()
			end,
			"go to references",
		},
		d = {
			function()
				require("telescope.builtin").lsp_definitions()
			end,
			"go to definition",
		},
		I = {
			function()
				require("telescope.builtin").lsp_implementations()
			end,
			"go to implementations",
		},
		D = {
			function()
				vim.lsp.buf.declaration()
			end,
			"go to declaration",
		},
	},

	z = {
		R = {
			function()
				require("ufo").openAllFolds()
			end,
			"Open all folds",
		},
		M = {
			function()
				require("ufo").closeAllFolds()
			end,
			"Close all folds",
		},
		r = {
			function()
				require("ufo").openFoldsExceptKinds()
			end,
			"Fold less",
		},
		m = {
			function()
				require("ufo").closeFoldsWith()
			end,
			"Fold more",
		},
	},

	["<C-l>"] = { "<cmd>cnext<cr>zz", "go to next entry in quickfix" },
	["<C-c>"] = { "<cmd>cprev<cr>zz", "go to previous entry in quickfix" },

	["<leader>"] = {
		["<leader>"] = { "<cmd>noh<CR>", "Disable Highlighting" },
		r = { "<cmd>Rooter<cr>", "Root vim" },
		z = {
			function()
				require("custom.tele").extensions.zoxide.list()
			end,
			"list zoxide dirs",
		},
		f = {
			name = "+find",
			s = {
				function()
					require("custom.tele").treesitter()
				end,
				"Treesitter Symbols",
			},
			g = {
				function()
					require("custom.tele").live_grep()
				end,
				"Live Grep in current dir",
			},
			f = {
				function()
					require("custom.tele").find_files()
				end,
				"Find Files in current dir",
			},
			t = {
				function()
					require("custom.tele").tags()
				end,
				"Browse workspace tags",
			},
			y = {
				function()
					require("custom.tele").extensions.neoclip.default()
				end,
				"Manage yank register",
			},
			b = {
				function()
					require("custom.tele").extensions.file_browser.file_browser()
				end,
				"Telescope file browser",
			},
			-- switch projects
			p = {
				function()
					require("custom.tele").git_workspace()
				end,
				"Telescope git workspace browser into find_files",
			},
		},
		t = {
			name = "+trouble",
			t = { "<cmd>TroubleToggle<cr>", "Toggle trouble" },
			a = { "<cmd>TodoTelescope<cr>", "Open TODOs in Telescope" },
			w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "Workspace Diagnostics" },
			d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "Document Diagnostics" },
			q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List" },
			l = { "<cmd>TroubleToggle loclist<cr>", "Loclist" },
			r = { "<cmd>TroubleToggle lsp_references<cr>", "Lsp Refrences" },
		},
		g = {
			name = "+git",
			g = {
				function()
					require("neogit").open()
				end,
				"Open NeoGit",
			},
			y = {
				function()
					require("gitlinker").get_buf_range_url("n")
				end,
				"copy link to file in remote to clipboard",
			},
			o = {
				function()
					require("gitlinker").get_buf_range_url("n", {
						action_callback = require("gitlinker.actions").open_in_browser,
					})
				end,
				"open current buffer's remote in browser",
			},
			Y = {
				function()
					require("gitlinker").get_repo_url()
				end,
				"copy homepage url to clipboard",
			},
			b = {
				"<cmd>Git blame<cr>",
				"Open git blame",
			},
		},
		d = {
			name = "+diffview",
			o = {
				function()
					diffview.open()
				end,
				"Open Diffview",
			},
			c = {
				function()
					diffview.close()
				end,
				"Close Diffview",
			},
			h = {
				function()
					diffview.file_history()
				end,
				"Diffview History",
			},
			f = {
				function()
					diffview.file_history(nil, "%")
				end,
				"Diffview File History",
			},
		},

		s = {
			name = "+shells",
			t = {
				function()
					terms["bottom"]:toggle()
				end,
				"Toggle bottom resource monitor",
			}, -- top
			f = {
				function()
					terms["bgshell"]:toggle()
				end,
				"Toggle random shell",
			}, -- float

			v = {
				function()
					terms["vterm"]:toggle()
				end,
				"Toggle side shell (horizontal split)",
			}, -- vertical
			h = {
				function()
					terms["hterm"]:toggle()
				end,
				"Toggle side shell (vertical split)",
			}, -- horizontal
		},
	},
}

-- visual mode mappings
local leaderv = {
	["<leader>"] = {
		d = {
			name = "+diffview",
			h = {
				function()
					local range = visual_selection_range()
					vim.pretty_print(vim.inspect(range))
					diffview.file_history(range)
				end,
				"Diffview file history",
			},
		},
		r = {
			name = "+R",
			s = { "<Plug>RSendSelection", "Send visual selection" },
		},
	},
	["/"] = { 'y/<C-R>"<CR>', "Search using visual mode" },
}

-- terminal mode mappings
local leadert = {
	[";;"] = { require("custom.utils").t("<C-\\><C-n>"), "Escape from terminal mode" },
}

-- register all settings
local wk = require("which-key")
wk.register(leadern, { mode = "n" })
wk.register(leaderv, { mode = "v" })
wk.register(leadert, { mode = "t" })

-- filetype-specific mappings
_G.which_key_conjure = function()
	local fenneln = {
		["<localleader>"] = {
			l = {
				name = "+log",
				s = "open in horizontal split",
				v = "open in vertical split",
				t = "open in new tab",
				q = "close all logs",
				r = "soft reset",
				R = "hard reset",
			},
			e = {
				name = "+evaluate",
				e = "form",
				ce = "form, comment",
				r = "root",
				cr = "root, comment",
				w = "word",
				cw = "word, comment",
				["!"] = "form, replace",
				f = "file from disk",
				b = "buffer",
			},
		},
	}

	local fennelv = {
		["<localleader>"] = {
			E = "evaluate current selection",
		},
	}

	wk.register(fenneln, { mode = "n", buffer = 0 })
	wk.register(fennelv, { mode = "v", buffer = 0 })
end

_G.which_key_lsp = function()
	local rn = {
		g = {
			d = {
				function()
					vim.lsp.buf.definition()
				end,
				"Go to definition",
			},
		},
		K = {
			function()
				vim.lsp.buf.hover()
			end,
			"Show tooltips/docs",
		},
		["["] = {
			d = {
				function()
					vim.diagnostic.goto_next()
				end,
				"Go to next diagnostic",
			},
		},
		["]"] = {
			d = {
				function()
					vim.diagnostic.goto_prev()
				end,
				"Go to previous diagnostic",
			},
		},
		["<leader>"] = {
			v = {
				w = {
					s = {
						function()
							vim.lsp.buf.workspace_symbol()
						end,
						"View Workspace Symbols",
					},
				},
				d = {
					function()
						vim.diagnostic.open_float()
					end,
					"Open float diagnostics",
				},
				c = {
					a = {
						function()
							vim.lsp.buf.code_action()
						end,
						"Open code actions",
					},
				},
				r = {
					r = {
						function()
							vim.lsp.buf.references()
						end,
						"Open references",
					},
					n = {
						function()
							vim.lsp.buf.rename()
						end,
						"Rename",
					},
				},
			},
		},
	}

	wk.register(rn, { mode = "n", buffer = 0 })
end

_G.which_key_r = function()
	local rn = {
		["<leader>"] = {
			r = {
				name = "+R",
				s = { "<Plug>RStart", "Start the R integration" },
				l = { "<Plug>RDSendLine", "Send current line" },
				p = { "<Plug>RPlot", "Plot data frame" },
				v = { "<Plug>RViewDF", "View data frame" },
				o = { "<Plug>RUpdateObjBrowser", "Update the Object Browser" },
				h = { "<Plug>RHelp", "Help" },
				f = { "<Plug>RSendFile", "Send the whole file" },
			},
		},
	}

	wk.register(rn, { mode = "n", buffer = 0 })
end

-- TODO: attempt to autostart netrep when detecting janet
-- TODO: package spork/netrepl using nix, provide it via overlay
vim.api.nvim_exec([[autocmd BufEnter *.fnl,*.rkt,*.hy,*.scm,*.janet,*.py :lua which_key_conjure()]], false)
vim.api.nvim_exec([[autocmd BufEnter *.r,*.Rmd :lua which_key_r()]], false)
