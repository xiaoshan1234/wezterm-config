local wezterm = require("wezterm")

local constants = require("config.constants")

local M = {}

function M.apply(config)
    config.font_dirs = { constants.CONFIG_DIR .. "/fonts" }
    config.font_locator = "ConfigDirsOnly"
    config.font = wezterm.font("Maple Mono NF CN")
    config.font_size = 12
end

return M
