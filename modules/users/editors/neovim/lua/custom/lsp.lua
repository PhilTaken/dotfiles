-- nvim_lsp object
local lsp = require("lspconfig")

local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("blink.cmp").get_lsp_capabilities({}, false)
)

capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

local lsp_extra_config = {}

lsp_extra_config["elixirls"] = {
	cmd = { "elixir-ls" },
}

lsp_extra_config["hls"] = {
	on_new_config = function(config, new_root)
		local cabalfiles = require("plenary.scandir").scan_dir(new_root, { depth = 1, search_pattern = ".*.cabal" })
		if #cabalfiles > 0 then
			config.cmd = { "haskell-language-server", "--lsp" }
		end
	end,
}

lsp_extra_config["fortls"] = {
	cmd = { "fortls", "--hover_signature", "--enable_code_actions" },
	root_dir = lsp.util.root_pattern(".git"),
}

lsp_extra_config["lua_ls"] = {
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
}

lsp_extra_config["rust_analyzer"] = {
	on_new_config = function(config, root_dir)
		local maxdepth = 4
		function find_direnvs(dir, depth)
			if depth == nil then
				depth = 0
			end
			local direnvs = {}
			local dirIter, dirObj = vim.loop.fs_scandir(dir)
			while true do
				local name, type = vim.loop.fs_scandir_next(dirIter, dirObj)

				if name == nil then
					break
				elseif name == ".direnv" then
					table.insert(direnvs, dir .. "/.direnv")
				elseif type == "directory" then
					if depth < maxdepth then
						local nested_direnvs = find_direnvs(dir .. "/" .. name, depth + 1)
						for _, v in ipairs(nested_direnvs) do
							table.insert(direnvs, v)
						end
					end
				end
			end

			return direnvs
		end

		local direnvs = find_direnvs(root_dir)

		for _, v in ipairs(direnvs) do
			table.insert(config.settings["rust-analyzer"].files.excludeDirs, v)
			table.insert(config.settings["rust-analyzer"].files.watcherExclude, v)
		end
	end,
	flags = {
		exit_timeout = 0,
	},
	settings = {
		["rust-analyzer"] = {
			files = {
				excludeDirs = {},
				watcherExclude = {},
			},
			imports = {
				granularity = {
					group = "module",
				},
				prefix = "self",
			},
			cargo = {
				buildScripts = {
					enable = true,
				},
			},
			procMacro = {
				enable = true,
				ignored = {
					leptos_macro = {
						-- optional: --
						-- "component",
						"server",
					},
				},
			},
		},
	},
}

local function get_python_path()
	return vim.fn.exepath("python")
end

lsp_extra_config["pylsp"] = {
	on_new_config = function(config)
		config.settings.pylsp.plugins.jedi.environment = get_python_path()
		config.settings.pylsp.plugins.pylsp_mypy.overrides = { "--python-executable", get_python_path(), true }
	end,
	settings = {
		pylsp = {
			plugins = {
				autopep8 = { enabled = false },
				yapf = { enabled = false },
				pyflakes = { enabled = false },
				pydocstyle = { enabled = false },
				jedi = {
					environment = nil,
				},
				jedi_completion = {
					include_params = true,
					fuzzy = true,
				},
				pylsp_mypy = {
					enabled = true,
					overrides = {},
					report_progress = true,
					live_mode = false,
				},
				ruff = {
					enabled = true,
					format = { "I" },
					unsafeFixes = false,
					extendIgnore = { "E501", "F401" },
					lineLength = 88,
				},
			},
		},
	},
}

lsp_extra_config["yamlls"] = {
	settings = {
		yaml = {
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require("schemastore").yaml.schemas(),
		},
	},
}

local enabled_lsps = {
	"ccls",
	"clojure_lsp",
	"elixirls",
	"erlangls",
	"fortls",
	"gleam",
	"hls",
	"lua_ls",
	"nil_ls",
	"pylsp",
	"r_language_server",
	"rust_analyzer",
	"svelte",
	"texlab",
	"ts_ls",
	"yamlls",
	"zls",
}

-- signature help
local signature_setup = {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		if client.server_capabilities.documentSymbolProvider then
			require("nvim-navic").attach(client, bufnr)
		end
		which_key_lsp()
	end,
}

for _, ls in ipairs(enabled_lsps) do
	local config
	if lsp_extra_config[ls] then
		config = vim.tbl_deep_extend("force", signature_setup, lsp_extra_config[ls])
	else
		config = signature_setup
	end
	require("lspconfig")[ls].setup(config)
end
