local wezterm = require("wezterm")
local catppuccin = require("catppuccin").setup {
    sync = false,
    flavour = "mocha",
}

return {
    enable_tab_bar = false,
    bold_brightens_ansi_colors = true,
    check_for_updates = false,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },

    window_close_confirmation = "NeverPrompt",
    window_decorations = "NONE",

    colors = catppuccin,

    dpi = 140,
    font = wezterm.font("Iosevka Comfy"),
    font_size = 13,
}
