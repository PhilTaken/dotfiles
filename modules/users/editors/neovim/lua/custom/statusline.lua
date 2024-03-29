local gl = require("galaxyline")
local utils = require("custom.statusline_utils")

-- Version control
local vcs = require("galaxyline.providers.vcs")

-- Core files information
local fileinfo = require("galaxyline.providers.fileinfo")

local condition = require("galaxyline.condition")

-- setup dev icons
require("nvim-web-devicons").setup()

local gls = gl.section
gl.short_line_list = { "defx", "packager", "vista", "NvimTree" }

local colors = {
	bg = "#282c34",
	fg = "#aab2bf",
	section_bg = "#38393f",
	blue = "#61afef",
	green = "#98c379",
	purple = "#c678dd",
	orange = "#e5c07b",
	red1 = "#e06c75",
	red2 = "#be5046",
	yellow = "#e5c07b",
	gray1 = "#5c6370",
	gray2 = "#2c323d",
	gray3 = "#3e4452",
	darkgrey = "#5c6370",
	grey = "#848586",
	middlegrey = "#8791A5",
}

-- Local helper functions
local buffer_not_empty = condition.buffer_not_empty

local checkwidth = function()
	return utils.has_width_gt(40) and condition.buffer_not_empty()
end

local mode_color = function()
	local mode_colors = {
		[110] = colors.green,
		[105] = colors.blue,
		[99] = colors.green,
		[116] = colors.blue,
		[118] = colors.purple,
		[22] = colors.purple,
		[86] = colors.purple,
		[82] = colors.red1,
		[115] = colors.red1,
		[83] = colors.red1,
	}

	local mode_color = mode_colors[vim.fn.mode():byte()]
	if mode_color ~= nil then
		return mode_color
	else
		return colors.purple
	end
end

-- Left side
gls.left[1] = {
	ViMode = {
		provider = function()
			local aliases = {
				[110] = " Normal ",
				[105] = " Insert ",
				[99] = "Command ",
				[116] = "Terminal",
				[118] = " Visual ",
				[22] = "V-Block ",
				[86] = " V-Line ",
				[82] = "Replace ",
				[115] = " Select ",
				[83] = " S-Line ",
			}
			vim.api.nvim_command("hi GalaxyViMode guibg=" .. mode_color())
			local alias = aliases[vim.fn.mode():byte()]
			if alias ~= nil then
				return "  " .. alias .. " "
			else
				return "  " .. vim.fn.mode():byte() .. " "
			end
		end,
		highlight = { colors.bg, colors.bg, "bold" },
	},
}

gls.left[2] = {
	FileIcon = {
		provider = {
			function()
				return "  "
			end,
			"FileIcon",
		},
		condition = condition.buffer_not_empty,
		highlight = {
			fileinfo.get_file_icon,
			colors.section_bg,
		},
	},
}

gls.left[3] = {
	FileName = {
		provider = fileinfo.get_current_file_path,
		condition = buffer_not_empty,
		highlight = { colors.fg, colors.section_bg },
		separator = "",
		separator_highlight = { colors.section_bg, colors.bg },
	},
}

gls.left[9] = {
	DiagnosticError = {
		provider = "DiagnosticError",
		icon = "  ",
		highlight = { colors.red1, colors.bg },
	},
}

gls.left[10] = {
	Space = {
		provider = function()
			return " "
		end,
		highlight = { colors.section_bg, colors.bg },
	},
}

gls.left[11] = {
	DiagnosticWarn = {
		provider = "DiagnosticWarn",
		icon = "  ",
		highlight = { colors.orange, colors.bg },
	},
}

gls.left[12] = {
	Space = {
		provider = function()
			return " "
		end,
		highlight = { colors.section_bg, colors.bg },
	},
}

gls.left[13] = {
	DiagnosticInfo = {
		provider = "DiagnosticInfo",
		icon = "  ",
		highlight = { colors.blue, colors.section_bg },
		separator = " ",
		separator_highlight = { colors.section_bg, colors.bg },
	},
}

-- Right side
gls.right[1] = {
	DiffAdd = {
		provider = "DiffAdd",
		condition = checkwidth,
		icon = "+",
		highlight = { colors.green, colors.bg },
	},
}
gls.right[2] = {
	DiffModified = {
		provider = "DiffModified",
		condition = checkwidth,
		icon = "~",
		highlight = { colors.orange, colors.bg },
	},
}
gls.right[3] = {
	DiffRemove = {
		provider = "DiffRemove",
		condition = checkwidth,
		icon = "-",
		highlight = { colors.red1, colors.bg },
		separator_highlight = { colors.section_bg, colors.bg },
	},
}

gls.right[4] = {
	Space = {
		provider = function()
			return " "
		end,
		highlight = { colors.section_bg, colors.bg },
		separator = "|",
		separator_highlight = { colors.gray2, colors.bg },
	},
}

gls.right[5] = {
	GitIcon = {
		provider = function()
			return "  "
		end,
		condition = buffer_not_empty and vcs.check_git_workspace,
		highlight = { colors.middlegrey, colors.bg },
	},
}

gls.right[6] = {
	GitBranch = {
		provider = "GitBranch",
		condition = buffer_not_empty,
		highlight = { colors.middlegrey, colors.bg },
	},
}

gls.right[7] = {
	PerCent = {
		provider = "LinePercent",
		highlight = { colors.gray2, colors.blue },
		separator = " ",
		separator_highlight = { colors.bg, colors.bg },
	},
}

-- Short status line
gls.short_line_left[1] = {
	BufferType = {
		provider = "FileTypeName",
		highlight = { colors.fg, colors.section_bg },
		separator = "  ",
		separator_highlight = { colors.section_bg, colors.bg },
	},
}

gls.short_line_right[1] = {
	BufferIcon = {
		provider = "BufferIcon",
		highlight = { colors.yellow, colors.section_bg },
		separator = "",
		separator_highlight = { colors.section_bg, colors.bg },
	},
}

-- Force manual load so that nvim boots with a status line
gl.load_galaxyline()
