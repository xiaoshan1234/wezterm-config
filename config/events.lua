--------------------------------------------------------------------------------
-- 事件回调：自定义 wezterm.on 行为（标签栏切换、URI 打开方式等）
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

function M.apply(_config)
    -- 切换标签栏显示：nil 视为默认开启（true），再取反得到新状态
    wezterm.on("toggle-tab-bar", function(window, _pane)
        local overrides = window:get_config_overrides() or {}
        overrides.enable_tab_bar = not (overrides.enable_tab_bar == nil and true or overrides.enable_tab_bar)
        window:set_config_overrides(overrides)
    end)

    -- 点击/打开链接：本地 file:// 在 Windows 上规范化路径后再用系统默认程序打开
    wezterm.on("open-uri", function(_window, _pane, uri)
        if uri:lower():match("^file://") then
            local normalized = uri
            -- 盘符路径 file://C:/... 补成 file:///C:/...，便于系统正确解析
            if normalized:match("^file://[A-Za-z]:") then
                normalized = normalized:gsub("^file://", "file:///")
            end
            normalized = normalized:gsub("\\\\", "/")

            wezterm.open_with(normalized)
            return true
        end

        wezterm.open_with(uri)
        return true
    end)
end

return M
