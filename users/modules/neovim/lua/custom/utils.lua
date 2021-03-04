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
