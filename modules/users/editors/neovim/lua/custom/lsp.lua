-- nvim_lsp object
local lsp = require("lspconfig")
local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities()
)
local navic = require("nvim-navic")
local configs = require("lspconfig/configs")

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
	flags = {
		exit_timeout = 0,
	},
	settings = {
		["rust-analyzer"] = {
			files = {
				excludeDirs = { ".direnv" },
				watcherExclude = { ".direnv" },
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

local function get_python_path(workspace)
	return vim.fn.exepath("python")
end

lsp_extra_config["pylsp"] = {
	on_new_config = function(config)
		config.settings.pylsp.plugins.jedi.environment = get_python_path(configs.root_dir)
		config.settings.pylsp.plugins.pylsp_mypy.overrides =
			{ "--python-executable", get_python_path(configs.root_dir), true }
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

local enabled_lsps = {
	"ccls",
	"nil_ls",
	"texlab",
	"tsserver",
	"erlangls",
	"r_language_server",
	"clojure_lsp",
	"hls",
	"elixirls",
	"fortls",
	"lua_ls",
	"rust_analyzer",
	"pylsp",
	"yamlls",
}

-- signature help
local signature_setup = {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		navic.attach(client, bufnr)
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
