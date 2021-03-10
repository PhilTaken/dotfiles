require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
        snippets_nvim = {
            priority = 10;
            sort = true;
        };
        nvim_lsp = {
            priority = 9;
            sort = true;
        };
        nvim_lua = {
            priority = 8;
            sort = true;
        };
        nvim_treesitter = {
            priority = 7;
            sort = true;
        };
        path = {
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
