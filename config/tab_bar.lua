local wezterm = require("wezterm")

local M = {}

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

local function tab_bar_colors(config)
    local scheme = resolve_scheme(config)
    if not scheme then
        return nil
    end

    local background = pick_color(scheme.background, "#1b1d2b")
    local foreground = pick_color(scheme.foreground, "#c0c0c0")
    local inactive_fg = foreground
    if scheme.ansi and scheme.ansi[8] then
        inactive_fg = scheme.ansi[8]
    elseif scheme.brights and scheme.brights[1] then
        inactive_fg = scheme.brights[1]
    end
    local transparent = "rgba(0,0,0,0)"
    local hover_bg = "rgba(0,0,0,0.25)"

    return {
        background = transparent,
        active_tab = {
            bg_color = transparent,
            fg_color = foreground,
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = transparent,
            fg_color = inactive_fg,
        },
        inactive_tab_hover = {
            bg_color = hover_bg,
            fg_color = foreground,
        },
        new_tab = {
            bg_color = transparent,
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
    config.use_fancy_tab_bar = false

    local colors = tab_bar_colors(config)
    if colors then
        config.colors = config.colors or {}
        config.colors.tab_bar = colors
    end

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

    wezterm.on("format-tab-title", function(tab, _tabs, _panes, cfg, hover, _max_width)
        local scheme = resolve_scheme(cfg)
        if not scheme then
            return tab.active_pane.title
        end

        local background = hover and "rgba(0,0,0,0.25)" or "rgba(0,0,0,0)"
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
