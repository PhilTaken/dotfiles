-- setup dev icons
require'nvim-web-devicons'.setup()

-- setup treesitter
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "json", "html", "toml",
        "bash", "css", "yaml"
    },
    highlight = {
        enable = true,
    },
}

