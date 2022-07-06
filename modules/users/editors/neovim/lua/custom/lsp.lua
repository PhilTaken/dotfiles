-- nvim_lsp object
local lsp = require'lspconfig'
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- set pythonpath (set to nil if no python in current env)
pcall(function() Pythonpath = io.popen('which python 2>/dev/null'):read() end)

-- signature help
local signature_setup = {
    capabilities = capabilities,
    on_attach = function(_, _)
        require'lsp_signature'.on_attach({
            bind = true,
            handler_opts = {
                border = "single"
            },
            use_lspsage = true,
        })
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

lsp.sumneko_lua.setup(custom_setup{
    cmd = { "lua-language-server" },
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                globals = {'vim'},
            },
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
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

lsp.ccls.setup(signature_setup) -- c/cpp
lsp.rnix.setup(signature_setup) -- nix
lsp.texlab.setup(signature_setup)
lsp.tsserver.setup(signature_setup)
lsp.erlangls.setup(signature_setup)

lsp.r_language_server.setup(signature_setup)
lsp.clojure_lsp.setup(signature_setup)
lsp.hls.setup(signature_setup)

