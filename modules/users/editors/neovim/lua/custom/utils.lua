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

--------------------------------------------------------------------------------

return M
