--------------------------------------------------------------------------------
-- 光标与次要窗格：闪烁曲线、样式、下划线粗细、非活动窗格淡化
--------------------------------------------------------------------------------

local M = {}

function M.apply(config)
    -- 光标闪烁进出动画
    config.cursor_blink_ease_in = "EaseOut"
    config.cursor_blink_ease_out = "EaseOut"
    -- 默认光标形状与闪烁周期（毫秒）
    config.default_cursor_style = "BlinkingBar"
    config.cursor_blink_rate = 650
    -- 下划线样式时的线条粗细
    config.underline_thickness = "1pt"
    -- 非当前 pane：保持饱和度与亮度，避免发灰（可按喜好调整）
    config.inactive_pane_hsb = { saturation = 1, brightness = 1 }
end

return M
