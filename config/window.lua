--------------------------------------------------------------------------------
-- 窗口外观与交互（标题栏、缩放、关闭确认等）
--------------------------------------------------------------------------------

local M = {}

function M.apply(config)
    -- 窗口装饰：仅保留可调整大小的边框，隐藏标题栏与窗口控制按钮
    -- 其他可选值示例："TITLE | RESIZE"（标题栏+可调大小）、"NONE"（无边框）
    config.window_decorations = "RESIZE"

    -- 调整字号时是否自动改变窗口尺寸；false 表示只改字号、窗口大小不变
    config.adjust_window_size_when_changing_font_size = false

    -- 关闭最后一个标签/窗口时是否弹出确认；NeverPrompt 表示不提示直接关闭
    config.window_close_confirmation = "NeverPrompt"
end

return M
