--------------------------------------------------------------------------------
-- 外观：配色、渲染、透明度、边距、滚动条与命令面板颜色
--------------------------------------------------------------------------------

local constants = require("config.constants")

local M = {}

function M.apply(config)
    config.color_schemes = config.color_schemes or {}
    config.color_schemes["Matrix Green"] = require("color.scheme_matrix_green")

    -- 默认配色（Leader+s 可切换；自定义见 config/scheme_matrix_green.lua）
    config.color_scheme = "Matrix Green"

    -- 前端与帧率：WebGpu + 高性能 GPU 偏好
    config.max_fps = 120
    config.front_end = "WebGpu"
    config.webgpu_power_preference = "HighPerformance"

    -- 整个窗口背景不透明度（1 为不透明）
    config.window_background_opacity = 0.90

    -- 静态背景图（与 background.lua 二选一或按需启用其一）
    -- config.window_background_image = constants.CONFIG_DIR .. "/images/4.jpg"

    -- 终端内容区与窗口边缘的留白
    config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    }

    -- 滚动条拇指（滑块颜色）
    config.colors = config.colors or {}
    config.colors.scrollbar_thumb = "#ffffff"

    -- QuickSelect：须用 ColorSpec 表，不能写在 color_schemes 里当纯 hex
    config.colors.quick_select_label_fg = { Color = "#2a2010" }
    config.colors.quick_select_label_bg = { Color = "#ffcb6b" }
    config.colors.quick_select_match_fg = { Color = "#000000" }
    config.colors.quick_select_match_bg = { Color = "#82aaff" }

    -- 命令面板（Ctrl+Shift+P 等）
    config.command_palette_bg_color = "rgba(0, 12, 6, 0.94)"
    config.command_palette_fg_color = "#a8d8b8"
end

return M
