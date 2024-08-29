local colors = {
	green = "String",
	blue = "Function",
	peach = "Identifier",
	purple = "Keyword",
	cyan = "Operator",
	pink = "Special",
}

local icons = {
	ui = {
		file = "",
		files = "",
		open_folder = "",
		config = "",
		close = "󰈆",
		git = "",
		elipsis = "󰇘",
		lightning = "⚡",
		branch = "",
		tree = "󰙅",
		lazy = "󰒲",
	},
}

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- v RECENT FILES v --

-- this line gets vim.v.oldfiles to be populated sooner during initial load so that it can be accessed below
vim.cmd("rshada")
local base_directory = vim.fn.getcwd()

-- functions used to style paths for buttons
local function remove_cwd(path)
	return path:gsub(base_directory .. "/", "")
end
local function shorten_home(path)
	return path:gsub(vim.env.HOME, "~")
end
local filtered_paths = {}

-- filter out buffers belonging to NvimTree
for _, path in ipairs(vim.v.oldfiles) do
	if not path:match("NvimTree_%d+$") then
		table.insert(filtered_paths, path)
	end
end

-- sort paths into those in the current working directory and those not
local desired_cwd_paths_amount = 5
local desired_global_paths_amount = 5
local cwd_paths = {}
local current_cwd_paths_amount = 0
local global_paths = {}
local current_global_paths_amount = 0
for _, path in ipairs(filtered_paths) do
	if string.find(path, base_directory, 1, true) then
		if current_cwd_paths_amount < desired_cwd_paths_amount then
			table.insert(cwd_paths, path)
			current_cwd_paths_amount = current_cwd_paths_amount + 1
		end
	else
		if current_global_paths_amount < desired_global_paths_amount then
			table.insert(global_paths, path)
			current_global_paths_amount = current_global_paths_amount + 1
		end
	end
end

-- truncate a path, rounding down to the nearest /
local function truncate_path(path, max_length)
	if not max_length then
		max_length = 50
	end
	if #path <= max_length then
		return path
	end
	local truncated_path = path:sub(-max_length)
	local first_slash_pos = truncated_path:find("/")
	if first_slash_pos then
		truncated_path = truncated_path:sub(first_slash_pos)
	end
	return icons.ui.elipsis .. truncated_path
end

-- map a list of paths to alpha buttons
local function map_path_to_button(paths, keybind_offset, style_func)
	local buttons = {}
	for i, path in ipairs(paths) do
		local path_desc = path
		if style_func then
			path_desc = style_func(path)
		end
		table.insert(
			buttons,
			dashboard.button(
				tostring(i + keybind_offset - 1),
				icons.ui.file .. "  " .. truncate_path(path_desc, 44),
				"<cmd>e " .. vim.fn.fnameescape(path) .. " <CR>"
			)
		)
	end
	return buttons
end

-- ^ RECENT FILES ^ --
-- v     GIT      v --

local function get_git_repo()
	local result = vim.fn.system("git remote get-url origin")
	if vim.v.shell_error ~= 0 then
		return ""
	end

	result = result:gsub(".git$", "")
	local repo_name = result:match(".*/([^\n]*)")
	if repo_name ~= nil then
		return icons.ui.git .. "  " .. repo_name
	else
		return ""
	end
end

local function get_git_branch()
	local result = vim.fn.system("git branch --show-current")
	if vim.v.shell_error ~= 0 then
		return ""
	end
	return icons.ui.branch .. "  " .. result:gsub("%s+", "")
end

-- ^      GIT     ^ --
-- v    LAYOUT    v --

local function header_lines(header)
	local lines = {}
	for line in string.gmatch(header, "[^\n]+") do
		table.insert(lines, line)
	end
	return lines
end

local ascii_header = [[
                                             
      ████ ██████           █████      ██
     ███████████             █████ 
     █████████ ███████████████████ ███   ███████████
    █████████  ███    █████████████ █████ ██████████████
   █████████ ██████████ █████████ █████ █████ ████ █████
 ███████████ ███    ███ █████████ █████ █████ ████ █████
██████  █████████████████████ ████ █████ █████ ████ ██████
]]

-- ^    LAYOUT    ^ --
-- v   SECTIONS   v --

local header = {
	type = "text",
	val = header_lines(ascii_header),
	opts = {
		position = "center",
		hl = colors.blue,
		-- wrap = "overflow";
	},
}

local git_section = {
	type = "text",
	val = get_git_repo() .. "  " .. get_git_branch(),
	opts = { position = "center", hl = colors.purple },
}

local cwd_section = {
	type = "text",
	val = icons.ui.open_folder .. "  " .. shorten_home(base_directory),
	opts = { position = "center", hl = colors.pink },
}

local recent_cwd_files_section_header = {
	type = "text",
	val = icons.ui.files .. "  Recent CWD Files                               ", -- these spaces are to aligh the text with section below
	opts = { position = "center", hl = colors.green },
}
local recent_cwd_files_section = {
	type = "group",
	val = map_path_to_button(cwd_paths, 0, remove_cwd),
	opts = {},
}

local recent_global_files_section_header = {
	type = "text",
	val = icons.ui.files .. "  Recent Files                                   ", -- these spaces are to aligh the text with section below
	opts = { position = "center", hl = colors.blue },
}
local recent_global_files_section = {
	type = "group",
	val = map_path_to_button(global_paths, 5, shorten_home),
	opts = {},
}

local actions_section_header = {
	type = "text",
	val = icons.ui.lightning .. " Actions                                        ", -- these spaces are to aligh the text with section below
	opts = { position = "center", hl = colors.purple },
}
local actions_section = {
	type = "group",
	val = {
		dashboard.button("g", icons.ui.git .. "  open neogit", "<cmd>Neogit<CR>"),
		dashboard.button("e", icons.ui.file .. "  new file", ":ene <BAR> startinsert <CR>"),
		dashboard.button("q", icons.ui.close .. "  quit nvim", ":qa<CR>"),
	},
	opts = { position = "center" },
}

-- ^   SECTIONS   ^ --

alpha.setup({
	layout = {
		{ type = "padding", val = 4 },
		header,
		{ type = "padding", val = 2 },
		git_section,
		cwd_section,
		{ type = "padding", val = 2 },
		actions_section_header,
		actions_section,
		{ type = "padding", val = 1 },
		recent_cwd_files_section_header,
		recent_cwd_files_section,
		{ type = "padding", val = 1 },
		recent_global_files_section_header,
		recent_global_files_section,
	},
})
