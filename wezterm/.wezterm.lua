local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

config.font = wezterm.font({
	family = "JetBrains Mono NL",
})
config.font_size = 14.0
config.line_height = 1.0

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.5
config.macos_window_background_blur = 28

return config
