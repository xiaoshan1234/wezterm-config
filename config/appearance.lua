--------------------------------------------------------------------------------
-- 外观：配色、渲染、透明度、边距、滚动条与命令面板颜色
--------------------------------------------------------------------------------

local constants = require("config.constants")

local M = {}

function M.apply(config)
    -- 默认配色（也可由快捷键临时覆盖）
    config.color_scheme = 'Ayu Mirage'

    -- 前端与帧率：WebGpu + 高性能 GPU 偏好
    config.max_fps = 120
    config.front_end = "WebGpu"
    config.webgpu_power_preference = "HighPerformance"

    -- 整个窗口背景不透明度（1 为不透明）
    config.window_background_opacity = 1

    -- 静态背景图（与 background.lua 二选一或按需启用其一）
    -- config.window_background_image = constants.CONFIG_DIR .. "/images/4.jpg"

    -- 终端内容区与窗口边缘的留白
    config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    }

    -- 滚动条拇指颜色（在配色上略提亮，便于辨认）
    config.colors = config.colors or {}
    config.colors.scrollbar_thumb = "#7b8aad"

    -- 命令面板（Ctrl+Shift+P 等）前景/背景
    config.command_palette_bg_color = "rgba(12, 14, 20, 0.92)"
    config.command_palette_fg_color = "#e6e9ef"
end

return M
