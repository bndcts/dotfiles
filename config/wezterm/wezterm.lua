-- Pull in the wezterm API
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Frappe"
config.font = wezterm.font('JetBrains Mono', { weight = 'Bold' })
return config
