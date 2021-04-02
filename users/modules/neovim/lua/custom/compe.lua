require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 0;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
        nvim_lsp = {
            priority = 10;
            sort = true;
        };
        nvim_lua = {
            priority = 9;
            sort = true;
        };
        snippets_nvim = {
            priority = 8;
            sort = true;
        };
        path = {
            priority = 7;
            sort = true;
        };
        nvim_treesitter = {
            priority = 6;
            sort = true;
        };
        tags = {
            priority = 5;
            sort = true;
        };
        buffer = {
            priority = 4;
            sort = true;
        };
        calc = {
            priority = 3;
            sort = true;
        };
    };
}
