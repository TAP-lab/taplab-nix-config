local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono Nerd Font")
config.font_size = 11.0

config.default_cursor_style = "BlinkingBar"

config.hide_tab_bar_if_only_one_tab = true

config.colors = {
    background = "#000000",
    foreground = "#FFFFFF",
    cursor_border = "#FFFFFF",
    cursor_bg = "#FFFFFF",
}

return config