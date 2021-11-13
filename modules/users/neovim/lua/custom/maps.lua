local cmd = vim.cmd
local util = require 'custom.utils'
-- local luasnip = require 'luasnip'

local Terminal  = require('toggleterm.terminal').Terminal

local lazygit = Terminal:new({
    cmd = "lazygit",
    direction = "float",
    float_opts = {
        border = "double",
    },
})

local bottom = Terminal:new({
    cmd = "btm",
    direction = "float",
    float_opts = {
        border = "double",
    },
})

local bgshell = Terminal:new({
    direction = "float",
    float_opts = {
        border = "double",
    }
})

-- autocommands
-- dont save passwords in swapfile...
cmd[[au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup]]

-- highlight yanks
cmd[[au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }]]

-- show some nice diagnostics
-- cmd[[au CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]]

-- disable line numbers in terminal
cmd[[au TermOpen * setlocal norelativenumber nonumber]]

-- vimwiki mappings
cmd[[au FileType vimwiki nmap <buffer><silent> <CR> <Plug>VimwikiFollowLink']]
cmd[[au FileType vimwiki nmap <buffer><silent> <Backspace> <Plug>VimwikiGoBackLink']]
cmd[[au FileType vimwiki nmap <buffer><silent> <leader>ww <Plug>VimwikiIndex']]
cmd[[au FileType vimwiki set syntax=markdown.pandoc]]

-- strip trailing whitespaces
cmd[[au FileType c,cpp,python,rust,nix,lua,ruby autocmd BufWritePre <buffer> :%s/\s\+$//e]]

-- redraw the vim window when necessary
cmd[[au VimResized * redraw!]]

--------------
-- MAPPINGS --
--------------

-- normal mode mappings
local leadern = {
    ["<F2>"] = { "<cmd>NvimTreeToggle<cr>", "Toggle nvimtree" },
    ["<A-y>"] = { function() require('Navigator').left() end, "Go left" },
    ["<A-n>"] = { function() require('Navigator').down() end, "Go down" },
    ["<A-e>"] = { function() require('Navigator').up() end, "Go up" },
    ["<A-o>"] = { function() require('Navigator').right() end, "Go right" },

    ["<A-a>"] = { "<C-a>", "Increment Number" },
    ["<A-x>"] = { "<C-x>", "Decrement Number" },

    ["<tab>"] = { "<cmd>bn<cr>", "Next Buffer" },
    ["<s-tab>"] = { "<cmd>bp<cr>", "Previous Buffer" },

    [";"] = { function() R('custom.tele').buffers() end, "Buffers" },
    [";;"] = { function() R('custom.tele').project_search() end, "Project Search" },

    K = { function() require('lspsaga.hover').render_hover_doc() end, "Hover Info" },

    ["<leader>"] = {
        ["<leader>"] = { "<cmd>noh<CR>", "Disable Highlighting"},
        f = {
            name = "+find",
            s = { function() R('custom.tele').treesitter() end, "Treesitter Symbols" },
            g = { function() R('custom.tele').live_grep() end, "Live Grep in current dir" },
            f = { function() R('custom.tele').find_files() end, "Find Files in current dir" },
            d = { function() R('custom.tele').find_dotfiles{} end, "Search in dotfiles" },
        },
        t = {
            name = "+trouble",
            t = { "<cmd>TroubleToggle<cr>", "Toggle trouble"},
            a = { "<cmd>TodoTrouble<cr>", "Open TODOs in trouble"},
            w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "Workspace Diagnostics"},
            d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "Document Diagnostics"},
            q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List"},
            l = { "<cmd>TroubleToggle loclist<cr>", "Loclist"},
            r = { "<cmd>TroubleToggle lsp_references<cr>", "Lsp Refrences"},
        },
        i = {
            name = "+iron",
            s = { "<cmd>IronRepl<cr>", "Start iron repl" },
            l = { "<Plug>(iron-send-line)", "Send single line" },
        },
        c = {
            name = "code generation",
            n = { function() require('neogen').generate() end, "Generate Comment from function"},
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
            name = "+R",
            s = { "<Plug>RStart", "Start the R integration"},
            l = { "<Plug>RDSendLine", "Send current line"},
            p = { "<Plug>RPlot", "Plot data frame"},
            v = { "<Plug>RViewDF", "View data frame"},
            o = { "<Plug>RUpdateObjBrowser", "Update the Object Browser"},
            h = { "<Plug>RHelp", "Help"},
            f = { "<Plug>RSendFile", "Send the whole file" },
        },
        g = {
            name = "+git",
            g = { function() lazygit:toggle() end, "Open LazyGit" },
            y = { function() require('gitlinker').get_buf_range_url('n') end, 'copy link to file in remote to clipboard' },
            o = { function() require('gitlinker').get_buf_range_url('n', {action_callback = require("gitlinker.actions").open_in_browser }) end, 'open current buffer\'s remote in browser' },
            Y = { function() require('gitlinker').get_repo_url() end, "copy homepage url to clipboard" },
        },
        s = {
            g = { function() lazygit:toggle() end, "Toggle lazygit interface" },
            h = { function() bottom:toggle() end, "Toggle bottom resource monitor"},
            s = { function() bgshell:toggle() end, "Toggle random shell" },
            c = { "<cmd>ToggleTermCloseAll<cr>", "Close all dangling terminals" },
        },
    },
}

-- visual mode mappings
local leaderv = {
    ["<leader>"] = {
        i = {
            name = "+iron",
            s = { "<Plug>(iron-visual-send)", "Send visual selection" },
        },
        r = {
            name = "R",
            s = { "<Plug>RSendSelection", "Send visual selection" }
        }
    },
    ["/"] = { 'y/<C-R>"<CR>', "Search using visual mode" },
}

-- terminal mode mappings
local leadert = {
    ["jj"] = { util.t("<C-\\><C-n>"), "Escape from terminal mode" }
}

local leaderi = {
    ["<c-o>"] = { function() require('luasnip').jump(1) end, "jump to next snippet placeholder" },
    ["<c-z>"] = { function() require('luasnip').jump(-1) end, "jump to previous snippet placeholder" },
}

local leaders = {
    ["<c-o>"] = { function() require('luasnip').jump(1) end, "jump to next snippet placeholder" },
    ["<c-z>"] = { function() require('luasnip').jump(-1) end, "jump to previous snippet placeholder" },
}

-- register all settings
local wk = require("which-key")
wk.register(leadern, { mode = "n" })
wk.register(leaderv, { mode = "v" })
wk.register(leadert, { mode = "t" })
wk.register(leaderi, { mode = "i" })
wk.register(leaders, { mode = "s" })
