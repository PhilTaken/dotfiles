--------------------------------------------------------------------------------
-- add all nvim plugins to runtimepath
local uv = vim.loop
local plugindir = "/home/nixos/Documents/personal/nvim_plugins/"

local dir = uv.fs_opendir(plugindir, nil, 200)
local entries = uv.fs_readdir(dir, nil)
uv.fs_closedir(dir)

local dirs = vim.tbl_filter(function(entry)
    return entry.type == "directory"
end, entries)

vim.tbl_map(function(entry)
    vim.api.nvim_exec("set runtimepath+=" .. plugindir .. entry.name, false)
end, dirs)

--------------------------------------------------------------------------------
-- for tab and shift-tab in completion
local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end
--------------------------------------------------------------------------------
-- generate autogroups

local cmd = vim.cmd
function _G.create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')
    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end
    cmd('augroup END')
end
