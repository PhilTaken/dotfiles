-- nvim_lsp object
local lsp = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local navic = require("nvim-navic")

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
                enable = true
            },
		},
	},
}

-- set pythonpath (set to nil if no python in current env)
lsp_extra_config["pylsp"] = {
	on_new_config = function(config)
		local appenv = vim.fs.find("appenv", {
			upward = true,
			type = "file",
			limit = 1,
			stop = vim.loop.os_homedir(),
			path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
		})

		local pythonpath
		if #appenv == 1 then
			pythonpath = io.popen("./appenv python -c 'import sys; print(sys.executable)'"):read()
		else
			pythonpath = io.popen("which python 2>/dev/null"):read()
		end
		config.settings.pylsp.plugins.jedi.environment = pythonpath
	end,
	settings = {
		pylsp = {
			plugins = {
				jedi = {
					environment = nil,
				},
				jedi_completion = {
					include_params = true,
					fuzzy = true,
				},
				pycodestyle = {
					maxLineLength = 150,
				},
			},
		},
	},
}

local enabled_lsps = {
	"ccls",
	"nil_ls",
	"nixd",
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
}

-- signature help
local signature_setup = {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		navic.attach(client, bufnr)
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
