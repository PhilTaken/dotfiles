-- nvim_lsp object
local lsp = require'lspconfig'

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

-- Enable lsp servers
lsp.rust_analyzer.setup{
    capabilities = capabilities,
    on_attach = signature_setup.on_attach,
}

lsp.texlab.setup(signature_setup)

lsp.ccls.setup(signature_setup)

lsp.pyright.setup(signature_setup)

lsp.rnix.setup(signature_setup)

lsp.tsserver.setup(signature_setup)

lsp.fortls.setup {
    cmd = { "fortls", "--hover_signature", "--enable_code_actions" },
    root_dir = lsp.util.root_pattern('.git'),
    on_attach = signature_setup.on_attach,
}

lsp.sumneko_lua.setup {
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
}

--lsp.julials.setup {
    --on_new_config = function(new_config, _)
        --local server_path = "/home/nixos/.julia/packages/LanguageServer/y1ebo/src"
	--local cmd = {
		--"julia",
		--"--project="..server_path,
		--"--startup-file=no",
		--"--history-file=no",
		--"-e", [[
		  --using Pkg;
		  --Pkg.instantiate()
		  --using LanguageServer; using SymbolServer;
		  --depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
		  --project_path = dirname(something(Base.current_project(pwd()), Base.load_path_expand(LOAD_PATH[2])))
		  --@info "Running language server" env=Base.load_path()[1] pwd() project_path depot_path
		  --server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path);
		  --server.runlinter = true;
		  --run(server);
		--]]
	--};
	--new_config.cmd = cmd
    --end
--}
