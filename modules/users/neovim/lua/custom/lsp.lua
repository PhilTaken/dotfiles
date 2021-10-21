-- nvim_lsp object
local lsp = require'lspconfig'
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

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


-- Enable lsp servers
lsp.elixirls.setup{
    cmd = { "elixir-ls" },
    on_attach = signature_setup.on_attach,
    capabilities = signature_setup.capabilities,
}

lsp.fortls.setup {
    cmd = { "fortls", "--hover_signature", "--enable_code_actions" },
    root_dir = lsp.util.root_pattern('.git'),
    on_attach = signature_setup.on_attach,
    capabilities = signature_setup.capabilities,
}

lsp.sumneko_lua.setup{
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
    on_attach = signature_setup.on_attach,
    capabilities = signature_setup.capabilities,
}

lsp.ccls.setup(signature_setup)
lsp.rnix.setup(signature_setup)
lsp.texlab.setup(signature_setup)
lsp.pyright.setup(signature_setup)
lsp.tsserver.setup(signature_setup)
lsp.erlangls.setup(signature_setup)
lsp.rust_analyzer.setup(signature_setup)
lsp.r_language_server.setup(signature_setup)

--lsp.pylsp.setup(signature_setup)
