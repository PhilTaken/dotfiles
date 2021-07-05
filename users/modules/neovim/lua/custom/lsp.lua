local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;

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

--lsp.flow.setup{
	--cmd = { "flow", "lsp" },
--}

lsp.tsserver.setup{}

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
