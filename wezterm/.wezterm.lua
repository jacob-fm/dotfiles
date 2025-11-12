local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.font = wezterm.font({
	family = "JetBrainsMono Nerd Font",
})
config.font_size = 14.0
config.line_height = 1.0

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

config.window_background_opacity = 0.8
config.macos_window_background_blur = 28

config.keys = {
	{
		key = "\\",
		mods = "CMD",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "SHIFT|CMD",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "CMD",
		action = act.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "k",
		mods = "SHIFT|CTRL",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "j",
		mods = "SHIFT|CTRL",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "h",
		mods = "SHIFT|CTRL",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "SHIFT|CTRL",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "k",
		mods = "CMD",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},
}

-- vim-like modal keybinds
local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.apply_to_config(config)
modal.set_default_keys(config)

return config
