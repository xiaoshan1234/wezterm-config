local wezterm = require("wezterm")

local M = {}

function M.apply(_config)
    -- 切换标签栏显示状态
    wezterm.on("toggle-tab-bar", function(window, _pane)
        local overrides = window:get_config_overrides() or {}
        overrides.enable_tab_bar = not (overrides.enable_tab_bar == nil and true or overrides.enable_tab_bar)
        window:set_config_overrides(overrides)
    end)

    wezterm.on("open-uri", function(_window, _pane, uri)
        if uri:lower():match("^file://") then
            local normalized = uri
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
