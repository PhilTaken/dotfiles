-- nvim_lsp object
local lsp = require'lspconfig'
local cpb = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').update_capabilities(cpb)
local navic = require('nvim-navic')

capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

-- set pythonpath (set to nil if no python in current env)
pcall(function() Pythonpath = io.popen('which python 2>/dev/null'):read() end)

-- signature help
local signature_setup = {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        navic.attach(client, bufnr)
        --require'lsp_signature'.on_attach(, bufnr)
    end,
}

-- extend signature_setup with custom arguments
local function custom_setup(...)
    local out = {}
    local arg = {...}
    for k,v in pairs(signature_setup) do out[k] = v end
    for k, v in pairs(arg) do out[k] = v end
    return out
end

-- Enable lsp servers
lsp.elixirls.setup(custom_setup{
    cmd = { "elixir-ls"}
})

lsp.fortls.setup(custom_setup{
    cmd = { "fortls", "--hover_signature", "--enable_code_actions" },
    root_dir = lsp.util.root_pattern('.git'),
})

--lsp.sumneko_lua.setup(custom_setup{
lsp.sumneko_lua.setup({
    on_attach = signature_setup.on_attach,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'},
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
})

lsp.rust_analyzer.setup(custom_setup{
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                loadOutDirsFromCheck = true
            },
            procMacro = {
                enable = true
            }
        }
    };
    init_options = {
        procMacro = { enable = true };
    };
})

lsp.pylsp.setup(custom_setup{
    settings = {
        pylsp = {
            plugins = {
                jedi = {
                    environment = Pythonpath,
                },
                jedi_completion = {
                    include_params = true,
                    fuzzy = true,
                },
                pycodestyle = {
                    maxLineLength = 150,
                },
                --flake8 = {
                    --enable = false,
                    --maxLineLength = 120,
                --},
            },
        },
    },
})

--lsp.pyright.setup(signature_setup)
local other_lsps = {
    'ccls',
    'rnix',
    'texlab',
    'tsserver',
    'erlangls',
    'r_language_server',
    'clojure_lsp',
    'hls'
}

for _, ls in ipairs(other_lsps) do
    require('lspconfig')[ls].setup(signature_setup)
end
