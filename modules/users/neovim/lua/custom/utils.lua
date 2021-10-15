--------------------------------------------------------------------------------
-- add all nvim plugins to runtimepath
local sourced = false
local uv = vim.loop
local plugindir = "/home/nixos/Documents/personal/nvim_plugins/"
local M = {}

if not sourced then
    local dir = uv.fs_opendir(plugindir, nil, 200)
    if dir ~= nil then
        local entries = uv.fs_readdir(dir, nil)
        uv.fs_closedir(dir)

        local dirs = vim.tbl_filter(function(entry)
            return entry.type == "directory"
        end, entries)

        vim.tbl_map(function(entry)
            vim.api.nvim_exec("set runtimepath+=" .. plugindir .. entry.name, false)
        end, dirs)
    end
end
sourced = true

--------------------------------------------------------------------------------
-- for tab and shift-tab in completion
M.check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

M.t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- from tjdevries
M.P = function(v)
  print(vim.inspect(v))
  return v
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
M.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return M.t "<C-n>"
  elseif M.check_back_space() then
    return M.t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end

M.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return M.t "<C-p>"
  else
    return M.t "<S-Tab>"
  end
end
--------------------------------------------------------------------------------

RELOAD = require('plenary.reload').reload_module

R = function(name)
    RELOAD(name)
    return require(name)
end

return M
