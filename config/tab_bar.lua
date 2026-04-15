--------------------------------------------------------------------------------
-- 标签栏：位置、宽度、与当前配色联动的 tab_bar 颜色与自定义标题格式
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

--- 从当前 config 解析出正在使用的配色表（自定义或内置）
local function resolve_scheme(config)
    if not config or not config.color_scheme then
        return nil
    end

    local scheme_name = config.color_scheme
    if config.color_schemes and config.color_schemes[scheme_name] then
        return config.color_schemes[scheme_name]
    end

    local builtins = wezterm.get_builtin_color_schemes()
    if builtins and builtins[scheme_name] then
        return builtins[scheme_name]
    end

    return nil
end

local function pick_color(primary, fallback)
    if primary and primary ~= "" then
        return primary
    end
    return fallback
end

-- 标签栏背景不透明度（1 = 完全不透明）
local TAB_BAR_ALPHA = 1
local TAB_BAR_HOVER_ALPHA = 1
-- 相对页面 background 加深：darken 因子 0~1，越大越暗；悬停时再略加深一点
local TAB_BAR_BG_DARKEN = 0.12
local TAB_BAR_HOVER_EXTRA_DARKEN = 0.04

--- 根据配色 background 计算标签栏条/悬停条背景色
---@param scheme table|nil
---@param alpha number
---@param hover boolean|nil
local function scheme_tab_bar_bg(scheme, alpha, hover)
    local hex = scheme and pick_color(scheme.background, "#1b1d2b") or "#1b1d2b"
    local darken_f = TAB_BAR_BG_DARKEN
    if hover then
        darken_f = math.min(1, TAB_BAR_BG_DARKEN + TAB_BAR_HOVER_EXTRA_DARKEN)
    end
    local ok, c = pcall(function()
        return wezterm.color.parse(hex):darken(darken_f):adjust_alpha(alpha)
    end)
    if ok and c then
        return c
    end
    return string.format("rgba(22, 24, 36, %g)", alpha)
end

--- 组装 config.colors.tab_bar 各子项颜色
local function tab_bar_colors(config)
    local scheme = resolve_scheme(config)
    if not scheme then
        return nil
    end

    local foreground = pick_color(scheme.foreground, "#c0c0c0")
    local inactive_fg = foreground
    if scheme.ansi and scheme.ansi[8] then
        inactive_fg = scheme.ansi[8]
    elseif scheme.brights and scheme.brights[1] then
        inactive_fg = scheme.brights[1]
    end
    local bar_bg = scheme_tab_bar_bg(scheme, TAB_BAR_ALPHA, false)
    local hover_bg = scheme_tab_bar_bg(scheme, TAB_BAR_HOVER_ALPHA, true)

    return {
        background = bar_bg,
        active_tab = {
            bg_color = bar_bg,
            fg_color = foreground,
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = bar_bg,
            fg_color = inactive_fg,
        },
        inactive_tab_hover = {
            bg_color = hover_bg,
            fg_color = foreground,
        },
        new_tab = {
            bg_color = bar_bg,
            fg_color = inactive_fg,
        },
        new_tab_hover = {
            bg_color = hover_bg,
            fg_color = foreground,
        },
    }
end

function M.apply(config)
    config.enable_tab_bar = true
    config.tab_bar_at_bottom = false
    config.show_new_tab_button_in_tab_bar = true
    config.show_tab_index_in_tab_bar = true
    config.show_tabs_in_tab_bar = true
    config.switch_to_last_active_tab_when_closing_tab = true
    config.tab_max_width = 25
    -- false 使用非「仿 macOS」的简洁标签条，便于与 format-tab-title 配合
    config.use_fancy_tab_bar = false

    local colors = tab_bar_colors(config)
    if colors then
        config.colors = config.colors or {}
        config.colors.tab_bar = colors
    end

    -- 新建标签按钮上的「+」字符与悬停色
    config.tab_bar_style = {
        new_tab = wezterm.format({
            { Foreground = { Color = "#5fbf7d" } },
            { Text = " + " },
        }),
        new_tab_hover = wezterm.format({
            { Foreground = { Color = "#7ad491" } },
            { Text = " + " },
        }),
    }

    -- 每个标签标题：序号 + 进程标题；当前标签标题用强调色
    wezterm.on("format-tab-title", function(tab, _tabs, _panes, cfg, hover, _max_width)
        local scheme = resolve_scheme(cfg)
        if not scheme then
            return tab.active_pane.title
        end

        local background = scheme_tab_bar_bg(scheme, hover and TAB_BAR_HOVER_ALPHA or TAB_BAR_ALPHA, hover)
        local foreground = pick_color(scheme.foreground, "#c0c0c0")
        local index_color = foreground
        if scheme.ansi and scheme.ansi[5] then
            index_color = scheme.ansi[5]
        elseif scheme.brights and scheme.brights[5] then
            index_color = scheme.brights[5]
        end

        local title = tab.active_pane.title or ""
        local intensity = tab.is_active and "Bold" or "Normal"
        local title_color = foreground
        if tab.is_active then
            title_color = "#e28a8a"
        end

        return wezterm.format({
            { Background = { Color = background } },
            { Foreground = { Color = index_color } },
            { Text = string.format(" %d:", tab.tab_index + 1) },
            { Foreground = { Color = title_color } },
            { Attribute = { Intensity = intensity } },
            { Text = " " .. title .. " " },
        })
    end)
end

return M
