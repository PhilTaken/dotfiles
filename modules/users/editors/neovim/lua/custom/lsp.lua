-- nvim_lsp object
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

lsp_extra_config["fortls"] = {
	cmd = { "fortls", "--hover_signature", "--enable_code_actions" },
	root_markers = { ".git" },
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
	on_attach = function(client, bufnr)
		local function update_direnv_ignores()
			local maxdepth = 4
			local function find_direnvs(dir, depth)
				if depth == nil then
					depth = 0
				end
				local direnvs = {}
				local dirIter, dirObj = vim.uv.fs_scandir(dir)
				while true do
					local name, type = vim.uv.fs_scandir_next(dirIter, dirObj)

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

			local dir = vim.fn.expand("%:p:h")
			local root = vim.fs.find(
				{ ".venv", ".envrc", "requirements.txt", "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
				{ path = dir, upward = true, stop = vim.fn.expand("~"), limit = 1 }
			)[1]

			local direnvs = find_direnvs(root)

			for _, v in ipairs(direnvs) do
				table.insert(client.config.settings["rust-analyzer"].files.excludeDirs, v)
				table.insert(client.config.settings["rust-analyzer"].files.watcherExclude, v)
			end
			client.notify(
				"workspace/didChangeConfiguration",
				{ settings = { rust_analyzer = client.config.settings.rust_analyzer } }
			)
		end

		vim.api.nvim_create_autocmd("BufEnter", { buffer = bufnr, callback = update_direnv_ignores })
		update_direnv_ignores()
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
	on_attach = function(client, bufnr)
		local function update_python_path()
			client.config.settings.pylsp.plugins.jedi.environment = get_python_path()
			client.config.settings.pylsp.plugins.pylsp_mypy.overrides =
				{ "--python-executable", get_python_path(), true }
			client.notify("workspace/didChangeConfiguration", { settings = { pylsp = client.config.settings.pylsp } })
		end

		vim.api.nvim_create_autocmd("BufEnter", { buffer = bufnr, callback = update_python_path })
		update_python_path()
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
	"lua_ls",
	"nil_ls",
	"pylsp",
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
	vim.lsp.config(ls, config)
	vim.lsp.enable(ls)
end
