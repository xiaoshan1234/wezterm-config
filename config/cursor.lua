local M = {}

function M.apply(config)
    config.cursor_blink_ease_in = "EaseOut"
    config.cursor_blink_ease_out = "EaseOut"
    config.default_cursor_style = "BlinkingBar"
    config.cursor_blink_rate = 650
    config.underline_thickness = "1pt"
    config.inactive_pane_hsb = { saturation = 1, brightness = 1 }
end

return M
