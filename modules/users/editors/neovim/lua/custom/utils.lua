--------------------------------------------------------------------------------
-- add all nvim plugins to runtimepath
local sourced = false
local uv = vim.loop
local plugindir = "/home/maelstroem/Documents/syncthing/personal/programming/nvim_plugins/"
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

M.t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- from tjdevries
M.P = function(v)
	print(vim.inspect(v))
	return v
end

--------------------------------------------------------------------------------

RELOAD = require("plenary.reload").reload_module

R = function(name)
	RELOAD(name)
	return require(name)
end

return M
