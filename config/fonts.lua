--------------------------------------------------------------------------------
-- 字体：从配置目录加载字体、主字体与字号
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local constants = require("config.constants")

local M = {}

function M.apply(config)
    -- 仅搜索 CONFIG_DIR/fonts，避免与系统字体混淆、保证 Maple Mono 等可预期加载
    config.font_dirs = { constants.CONFIG_DIR .. "/fonts" }
    config.font_locator = "ConfigDirsOnly"
    config.font = wezterm.font("Maple Mono NF CN")
    config.font_size = 12
end

return M
