require 'format'
require 'status'
require 'event'

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- keybinds
-- デフォルトのkeybindを無効化
config.disable_default_key_bindings = true
-- `keybinds.lua`を読み込み
local keybind = require 'keybinds'
-- keybindの設定
config.keys = keybind.keys
config.key_tables = keybind.key_tables
-- Leaderキーの設定
config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }
config.use_ime = true

-- colors
config.color_scheme = "nord"
config.window_background_opacity = 0.93
config.macos_window_background_blur = 20
-- font
config.font = require("wezterm").font("HackGen Console NF")
config.font_size = 13.0
config.window_frame = {
  font = wezterm.font { family ='Roboto', weight = 'Bold' },
  font_size = 11.0,
}

-- status
config.status_update_interval = 1000

-- window decorations
config.window_decorations = "RESIZE"

-- mouse binds
config.mouse_bindings = require('mousebinds').mouse_bindings

-- macOSでIMEが有効な時にCtrlキーがうまく動作しない
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'

-- and finally, return the configuration to wezterm
return config


