-- autocommands
-- dont save passwords in swapfile...
vim.cmd[[au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup]]

-- highlight yanks
vim.cmd[[au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }]]

-- disable line numbers in terminal
vim.cmd[[au TermOpen * setlocal norelativenumber nonumber]]

-- strip trailing whitespaces
vim.cmd[[au FileType c,cpp,python,rust,nix,lua,ruby,r autocmd BufWritePre <buffer> :%s/\s\+$//e]]

-- create non-exist files under cursor
vim.cmd[[map gf :e <cfile><CR>]]

-- terminals
local toggleterm = require('toggleterm')
local terms = require('custom.terminals')
local diffview = require('diffview')

local function visual_selection_range()
  -- https://github.com/neovim/neovim/pull/13896#issuecomment-774680224
  --local csrow = vim.api.nvim_buf_get_mark(0, "<")[1]
  --local cerow = vim.api.nvim_buf_get_mark(0, ">")[1]
  local csrow = vim.fn.getpos('v')[2]
  local cerow = vim.api.nvim_win_get_cursor(0)[1]
  if csrow <= cerow then
    return { csrow, cerow }
  else
    return { cerow, csrow }
  end
end

--------------
-- MAPPINGS --
--------------

-- normal mode mappings (global)
local leadern = {
    ["<F2>"] = { "<cmd>NvimTreeToggle<cr>", "Toggle nvimtree" },
    ["<A-y>"] = { function() require('Navigator').left() end, "Go left" },
    ["<A-n>"] = { function() require('Navigator').down() end, "Go down" },
    ["<A-e>"] = { function() require('Navigator').up() end, "Go up" },
    ["<A-o>"] = { function() require('Navigator').right() end, "Go right" },

    ["<A-a>"] = { "<C-a>", "Increment Number" },
    ["<A-x>"] = { "<C-x>", "Decrement Number" },

    ["<c-tab>"] = { "<Plug>(CybuLastusedNext)", "Next Buffer" },
    ["<c-s-tab>"] = { "<Plug>(CybuLastusedPrev)", "Previous Buffer" },
    ["<tab>"] = { "<Plug>(CybuNext)", "Next Buffer" },
    ["<s-tab>"] = { "<Plug>(CybuPrev)", "Previous Buffer" },
    --["<tab>"] = { "<cmd>bn<cr>", "Next Buffer" },
    --["<s-tab>"] = { "<cmd>bp<cr>", "Previous Buffer" },

    [";"] = { function() R('custom.tele').buffers() end, "Buffers" },

    z = {
        R = { function() require('ufo').openAllFolds() end, "Open all folds" },
        M = { function() require('ufo').closeAllFolds() end, "Close all folds" },
        r = { function() require('ufo').openFoldsExceptKinds() end, "Fold less" },
        m = { function() require('ufo').closeFoldsWith() end, "Fold more" },
    },

    ["<C-l>"] = { "<cmd>cnext<cr>zz", "go to next entry in quickfix" },
    ["<C-c>"] = { "<cmd>cprev<cr>zz", "go to previous entry in quickfix" },

    --K = {
        --function()
            --local winid = require('ufo').peekFoldedLinesUnderCursor()
            --if not winid then
                --vim.lsp.buf.hover()
            --end
        --end
    --},

    ["<leader>"] = {
        ["<leader>"] = { "<cmd>noh<CR>", "Disable Highlighting" },
        r = { "<cmd>Rooter<cr>", "Root vim" },
        z = { function() R('custom.tele').extensions.zoxide.list() end, "list zoxide dirs" },
        f = {
            name = "+find",
            s = { function() R('custom.tele').treesitter() end, "Treesitter Symbols" },
            g = { function() R('custom.tele').live_grep() end, "Live Grep in current dir" },
            f = { function() R('custom.tele').find_files() end, "Find Files in current dir" },
            d = { function() R('custom.tele').find_dotfiles{} end, "Search in dotfiles" },
            t = { function() R('custom.tele').tags() end, "Browse workspace tags" },
            y = { function() R('custom.tele').extensions.neoclip.default() end, "Manage yank register" },
            b = { function() R('custom.tele').extensions.file_browser.file_browser() end, "Telescope file browser" },
        },
        t = {
            name = "+trouble",
            t = { "<cmd>TroubleToggle<cr>", "Toggle trouble" },
            a = { "<cmd>TodoTrouble<cr>", "Open TODOs in trouble" },
            w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "Workspace Diagnostics" },
            d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "Document Diagnostics" },
            q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List" },
            l = { "<cmd>TroubleToggle loclist<cr>", "Loclist" },
            r = { "<cmd>TroubleToggle lsp_references<cr>", "Lsp Refrences" },
        },
        m = {
            name = "+make",
            -- TODO: make keybinds
        },
        -- TODO: maybe move to autocommands down below (like fennel, python)
        l = {
            name = "+lsp",
            n = { function() vim.lsp.buf.rename() end, "Rename Variable" },
            c = { function() vim.lsp.buf.code_action() end, "Code Action" },
            f = { function() vim.lsp.buf.formatting() end, "Formatting" },
            d = { function() vim.lsp.buf.definition() end, "Preview Definition" },
            e = { function() vim.diagnostic.open_float() end, "Diagnostics float" },
            k = { function() vim.lsp.buf.hover() end, "Show tooltips/docs"},
            -- symbols outline
        },
        g = {
            name = "+git",
            g = { function() R('custom.terminals')['lazygit']:toggle() end, "Open LazyGit" },
            y = { function() R('gitlinker').get_buf_range_url('n') end, 'copy link to file in remote to clipboard' },
            o = { function() R('gitlinker').get_buf_range_url('n', {
                action_callback = R("gitlinker.actions").open_in_browser
            }) end, 'open current buffer\'s remote in browser' },
            Y = { function() R('gitlinker').get_repo_url() end, "copy homepage url to clipboard" },
            w = {
                name = "+worktree",
                s = { function() R('custom.tele').extensions.git_worktree.git_worktrees() end, "Switch worktree branch" },
                c = { function() R('custom.tele').extensions.git_worktree.create_git_worktree() end, "create worktree branch" },
            },
        },
        d = {
            name = "+diffview";
            o = { function() diffview.open() end, "Open Diffview" },
            c = { function() diffview.close() end, "Close Diffview"},
            h = { function() diffview.file_history() end, "Diffview History"},
            f = { function() diffview.file_history(nil, "%") end, "Diffview File History"},
        };

        p = {
            name = "+present",
            --p = { function() R('custom.tele').extensions.project.project{} end, "Browse projects" },
            p = { "<cmd>PresentEnable", "Start presenting" },
            s = { "<cmd>PresentDisable", "Stop presenting" },
        },
        s = {
            name = "+shells",
            g = { function() terms['lazygit']:toggle() end, "Toggle lazygit interface" },      -- git
            t = { function() terms['bottom']:toggle() end, "Toggle bottom resource monitor" }, -- top
            f = { function() terms['bgshell']:toggle() end, "Toggle random shell" },           -- float

            v = { function() terms['vterm']:toggle() end, "Toggle side shell (horizontal split)" },               -- vertical
            h = { function() terms['hterm']:toggle() end, "Toggle side shell (vertical split)" },               -- horizontal

            l = { function() toggleterm.send_lines_to_terminal("single_line", true, terms['vterm'].id) end, "Send current line" }, -- send Line
        },
    },
}

-- visual mode mappings
local leaderv = {
    ["<leader>"] = {
        d = {
            name = "+diffview";
            h = { function()
                local range = visual_selection_range()
                vim.pretty_print(vim.inspect(range))
                diffview.file_history(range)
            end,
            "Diffview file history" },
        },
        r = {
            name = "+R",
            s = { "<Plug>RSendSelection", "Send visual selection" }
        },
        s = {
            name = "+terminal",
            l = { "<cmd>ToggleTermSendVisualLines " .. terms['vterm'].id .. "<cr>", "Send Visual Lines" },
            v = { "<cmd>ToggleTermSendVisualSelection " .. terms['vterm'].id .. "<cr>", "Send Visual Selection" },
            --l = { function() toggleterm.send_lines_to_terminal("visual_lines", true, terms['vterm'].id) end, "Send Visual Lines" },
            --v = { function() toggleterm.send_lines_to_terminal("visual_selection", true, terms['vterm'].id) end, "Send Visual Selection" },
        }
    },
    ["/"] = { 'y/<C-R>"<CR>', "Search using visual mode" },
}

-- terminal mode mappings
local leadert = {
    [";;"] = { R('custom.utils').t("<C-\\><C-n>"), "Escape from terminal mode" }
}

local leaderi = {
    ["<c-o>"] = { function() R('luasnip').jump(1) end, "jump to next snippet placeholder" },
    ["<c-z>"] = { function() R('luasnip').jump(-1) end, "jump to previous snippet placeholder" },
}

local leaders = {
    ["<c-o>"] = { function() R('luasnip').jump(1) end, "jump to next snippet placeholder" },
    ["<c-z>"] = { function() R('luasnip').jump(-1) end, "jump to previous snippet placeholder" },
}

-- register all settings
local wk = R("which-key")
wk.register(leadern, { mode = "n" })
wk.register(leaderv, { mode = "v" })
wk.register(leadert, { mode = "t" })
wk.register(leaderi, { mode = "i" })
wk.register(leaders, { mode = "s" })

-- filetype-specific mappings
_G.which_key_conjure = function()
    local fenneln = {
        ['<localleader>'] = {
            l = {
                name = "+log",
                s = "open in horizontal split",
                v = "open in vertical split",
                t = "open in new tab",
                q = "close all logs",
                r = "soft reset",
                R = "hard reset",
            },
            e = {
                name = "+evaluate",
                e = "form",
                ce = "form, comment",
                r = "root",
                cr = "root, comment",
                w = "word",
                cw = "word, comment",
                ['!'] = "form, replace",
                f = "file from disk",
                b = "buffer",
            }
        },
    }

    local fennelv = {
        ['<localleader>'] = {
            E = "evaluate current selection",
        },
    }

    wk.register(fenneln, {mode = "n", buffer = 0})
    wk.register(fennelv, {mode = "v", buffer = 0})
end

_G.which_key_r = function()
    local rn = {
        ['<leader>'] = {
            r = {
                name = "+R",
                s = { "<Plug>RStart", "Start the R integration" },
                l = { "<Plug>RDSendLine", "Send current line" },
                p = { "<Plug>RPlot", "Plot data frame" },
                v = { "<Plug>RViewDF", "View data frame" },
                o = { "<Plug>RUpdateObjBrowser", "Update the Object Browser" },
                h = { "<Plug>RHelp", "Help" },
                f = { "<Plug>RSendFile", "Send the whole file" },
            },
        }
    }

    wk.register(rn, {mode = "n", buffer = 0})
end

-- TODO: attempt to autostart netrep when detecting janet
-- TODO: package spork/netrepl using nix, provide it via overlay
vim.api.nvim_exec([[autocmd BufEnter *.fnl,*.rkt,*.hy,*.scm,*.janet,*.py :lua which_key_conjure()]], false)
vim.api.nvim_exec([[autocmd BufEnter *.r,*.Rmd :lua which_key_r()]], false)
