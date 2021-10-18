-- nvim_lsp object
local lsp = require'lspconfig'
local coq = require'coq'

local capabilities = vim.lsp.protocol.make_client_capabilities()
--capabilities.textDocument.completion.completionItem.snippetSupport = true;

-- signature help
local signature_setup = {
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

local coq_caps = coq.lsp_ensure_capabilities(signature_setup)

-- Enable lsp servers
lsp.rust_analyzer.setup{coq.lsp_ensure_capabilities{
    capabilities = capabilities,
    on_attach = signature_setup.on_attach,
}}

lsp.elixirls.setup{coq.lsp_ensure_capabilities{
    cmd = { "elixir-ls" },
    on_attach = signature_setup.on_attach,
}}

lsp.fortls.setup {coq.lsp_ensure_capabilities{
    cmd = { "fortls", "--hover_signature", "--enable_code_actions" },
    root_dir = lsp.util.root_pattern('.git'),
    on_attach = signature_setup.on_attach,
}}

lsp.sumneko_lua.setup{coq.lsp_ensure_capabilities{
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
}}

lsp.texlab.setup(coq_caps)
lsp.ccls.setup(coq_caps)
lsp.rnix.setup(coq_caps)
lsp.tsserver.setup(coq_caps)
lsp.erlangls.setup(coq_caps)
lsp.r_language_server.setup(coq_caps)

lsp.pyright.setup(coq_caps)
--lsp.pylsp.setup(signature_setup)

