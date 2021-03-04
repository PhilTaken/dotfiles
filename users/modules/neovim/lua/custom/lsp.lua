local cmd = vim.cmd

cmd("autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;

-- set escape in insert mode to leave
local actions = require('telescope.actions')
require('telescope').setup{
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close
            },
        },
    }
}

-- nvim_lsp object
local lsp = require'lspconfig'

-- Enable lsp servers
lsp.rust_analyzer.setup{
    capabilities = capabilities,
}
lsp.texlab.setup{}
lsp.ccls.setup{}
lsp.pyright.setup{}
lsp.rnix.setup{}
lsp.fortls.setup {
    root_dir = lsp.util.root_pattern('.git');
}
lsp.sumneko_lua.setup {
    cmd = { "lua-language-server" };
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
    };
}
