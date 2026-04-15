--------------------------------------------------------------------------------
-- 全局常量：配置目录路径、快捷键配色列表等
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

-- WezTerm 配置所在目录（本仓库根路径）
M.CONFIG_DIR = wezterm.config_dir

-- Leader+s 配色选择器使用的内置/已知配色名（需与 WezTerm 内置或自定义 scheme 名一致）
M.COLOR_SCHEMES = {
    "Ayu Mirage",
    "Tokyo Night",
    "Catppuccin Mocha",
    "Catppuccin Latte",
    "One Dark (Gogh)",
    "Dracula",
    "Gruvbox Dark (Gogh)",
    "Nord",
    "Solarized Dark (Gogh)",
    "Rose Pine",
}

return M
