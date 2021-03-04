local g = vim.g

--- global options
g.rooter_targets = '/,*'
g.rooter_patterns = { '.git/' }
g.rooter_resolve_links = 1

g.NERDDefaultAlign = "left"
g.NERDToggleCheckAllLines = 1
g.UltiSnipsExpandTrigger = "JJ"
g.UltiSnipsJumpForwardTrigger = "<c-j>"
g.UltiSnipsJumpBackwardTrigger = "<c-k>"
g.UltiSnipsEditSplit = "horizontal"
g.pear_tree_smart_closers = 1
g.pear_tree_smart_openers = 1
g.pear_tree_smart_backspace = 1

g.tmux_navigator_no_mappings = 1
g.tmux_navigator_save_on_switch = 1


g.completion_enable_snippet = "UltiSnips"
g.completion_chain_complete_list = {
    { complete_items = { 'lsp', 'snippet', 'path' } },
    { complete_items = { 'ts', 'buffers' } },
}
g.completion_auto_change_source = 1

g.vimwiki_key_mappings = {
    global = 0,
    links = 0,
    html = 0,
    mouse = 0,
    table_mappings = 0,
}

g.firenvim_config = {
    localSettings = {
        ['.*'] = {
            takeover = 'never'
        }
    }
}

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
    path = true;
    buffer = false;
    calc = true;
    vsnip = false;
    nvim_lsp = true;
    nvim_lua = true;
    spell = false;
    tags = false;
    snippets_nvim = true;
    treesitter = true;
  };
}
