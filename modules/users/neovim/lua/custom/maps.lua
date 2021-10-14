local cmd = vim.cmd
local map = vim.api.nvim_set_keymap
local options = { noremap = true; silent = true; }

-- autocommands
cmd[[au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup]]
cmd[[au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }]]
cmd[[au CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]]
cmd[[au TermOpen * setlocal norelativenumber nonumber]]

-- vimwiki mappings
cmd[[au FileType vimwiki nmap <buffer><silent> <CR> <Plug>VimwikiFollowLink']]
cmd[[au FileType vimwiki nmap <buffer><silent> <Backspace> <Plug>VimwikiGoBackLink']]
cmd[[au FileType vimwiki nmap <buffer><silent> <leader>ww <Plug>VimwikiIndex']]
cmd[[au FileType vimwiki set syntax=markdown.pandoc]]

-- strip trailing whitespaces
cmd[[au FileType c,cpp,python,rust,nix,lua,ruby autocmd BufWritePre <buffer> :%s/\s\+$//e]]

cmd[[au VimResized * redraw!]]
cmd[[au TextYankPost * silent! lua vim.highlight.on_yank()]]

-- for easy buffer navigation
map('n', '<Tab>', ':bn<CR>', {})
map('n', '<S-Tab>', ':bp<CR>', {})

-- remap number in/decrement
map('n', '<A-a>', 'C-a', options)
map('n', '<A-x>', 'C-x', options)

local leadern = {
    [";"] = { function() R('custom.tele').buffers() end, "Buffers" },
    [";;"] = { function() R('custom.tele').project_search() end, "Project Search" },
    K = { function() require('lspsaga.hover').render_hover_doc() end, "Hover Info" },

    ["<leader>"] = {
        ["<leader>"] = { "<cmd>noh<CR>", "Disable Highlighting"},
        s = { function() R('custom.tele').treesitter() end, "Treesitter Symbols" },
        g = { function() R('custom.tele').live_grep() end, "Live Grep in current dir" },
        f = { function() R('custom.tele').find_files() end, "Find Files in current dir" },
        d = { function() R('custom.tele').find_dotfiles{} end, "Search in dotfiles" },
        t = {
            name = "+trouble",
            t = { "<cmd>TroubleToggle<cr>", "Toggle trouble"},
            w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "Workspace Diagnostics"},
            d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "Document Diagnostics"},
            q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List"},
            l = { "<cmd>TroubleToggle loclist<cr>", "Loclist"},
            r = { "<cmd>TroubleToggle lsp_references<cr>", "Lsp Refrences"},
        },
        i = {
            name = "+iron",
            l = { "<Plug>(iron-send-line)", "Send single line" },
        },
    },
    l = {
        name = "+lsp",
        s = { function() require('lspsaga.signaturehelp').signature_help() end, "Signature Help" },
        n = { function() require('lspsaga.rename').rename() end, "Rename Variable" },
        f = { function() require('lspsaga.provider').lsp_finder() end, "Lsp Finder" },
        c = { function() require('lspsaga.codeaction').code_action() end, "Code Action" },
        d = { function() require('lspsaga.provider').preview_definition() end, "Preview Definition"},
        ["["] = { function() require('lspsaga.diagnostic').lsp_jump_diagnostic_prev() end, "Previous Diagnostic"},
        ["]"] = { function() require('lspsaga.diagnostic').lsp_jump_diagnostic_next() end, "Next Diagnostic"},
        ["="] = { function() vim.lsp.buf.formatting() end, "Formatting" },
    },
    r = {
        name = "R",
        s = { "<Plug>RStart", "Start the R integration"},
        l = { "<Plug>RDSendLine", "Send current line"},
        p = { "<Plug>RPlot", "Plot data frame"},
        v = { "<Plug>RViewDF", "View data frame"},
        o = { "<Plug>RUpdateObjBrowser", "Update the Object Browser"},
        h = { "<Plug>RHelp", "Help"},
        f = { "<Plug>RSendFile", "Send the whole file" },
    },

    ["<A-y>"] = { function() require('Navigator').left() end, "Go left" },
    ["<A-n>"] = { function() require('Navigator').down() end, "Go down" },
    ["<A-e>"] = { function() require('Navigator').up() end, "Go up" },
    ["<A-o>"] = { function() require('Navigator').right() end, "Go right" },
}

local leaderv = {
    ["<leader>"] = {
        i = {
            name = "+iron",
            s = { "<Plug>(iron-send-visual)", "Send visual selection" },
        },
    }
}

local wk = require("which-key")
wk.register(leadern, { mode = "n" })
wk.register(leaderv, { mode = "v" })

wk.register

map('v', '<LocalLeader>ss', '<Plug>RSendSelection', { silent = true; })

-- search using visual mode
map('v', '/', 'y/<C-R>"<CR>', options)

-- escape in/out of terminal mode
map('t', 'jj', '<C-\\><C-n>', { noremap = true; })

----------------------------------------------

-- tab completion
map("i", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
map("s", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- compe
map('i', '<C-Space>', [[compe#complete()]],              {noremap = true; expr = true; silent = true;})
map('i', '<CR>',      [[compe#confirm('<CR>')]],         {noremap = true; expr = true; silent = true;})
map('i', '<C-f>',     [[compe#scroll({ 'delta': +4 })]], {noremap = true; expr = true; silent = true;})
map('i', '<C-d>',     [[compe#scroll({ 'delta': -4 })]], {noremap = true; expr = true; silent = true;})
