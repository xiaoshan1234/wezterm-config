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

--- 去掉标题里常见的 WezTerm 占位文案，便于露出 tmux/远端 真实窗口名
local function strip_wezterm_title_noise(s)
    if not s or s == "" then
        return ""
    end
    local t = s
    t = t:gsub("^%s+", ""):gsub("%s+$", "")
    t = t:gsub("^WezTerm%s*[|%s%-]*", "")
    t = t:gsub("^wezterm%s*[|%s%-]*", "")
    t = t:gsub("^WezTerm%.app%s*", "")
    t = t:gsub("^wezterm%-gui%.exe%s*", "")
    t = t:gsub("^wezterm%.exe%s*", "")
    t = t:gsub("%s*[%-|%s]+%s*[Ww]ez[Tt]erm%s*$", "")
    t = t:gsub("^%s+", ""):gsub("%s+$", "")
    return t
end

--- 判断是否仍是「只有 WezTerm / 可执行文件名」这类无区分标题
local function looks_like_generic_host_title(s)
    local l = (s or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if l == "" then
        return true
    end
    if l == "wezterm" or l == "wezterm-gui" or l == "wezterm.exe" or l == "wezterm-gui.exe" then
        return true
    end
    if l:match("^wezterm") and #l <= 16 then
        return true
    end
    return false
end

--- SSH 域在标签上展示的短名：去掉 SSHMUX: / SSH: 等前缀，与 ssh_domains 里 name 对齐
local function ssh_domain_display_name(domain)
    if not domain or domain == "" then
        return nil
    end
    if domain:match("^SSHMUX:") then
        return domain:gsub("^SSHMUX:", "")
    end
    if domain:match("^SSH:") then
        return domain:gsub("^SSH:", "")
    end
    return domain
end

--- 仅「ssh」占位类标题，应用域名替换；有实质内容（如 vim、路径）则保留
local function looks_like_generic_ssh_title(s)
    local l = (s or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if l == "ssh" or l == "ssh.exe" then
        return true
    end
    if l == "wezterm ssh" then
        return true
    end
    return false
end

--- 非 tmux 域下，把空/泛 WezTerm/字面「ssh」标题换成域短名（含 ssh_domains.name 如 10.18.0.20、xp）
local function prefer_ssh_name_when_placeholder(text, domain)
    if domain == "" or domain:lower():find("tmux", 1, true) then
        return text
    end
    local short = ssh_domain_display_name(domain)
    if not short or short == "" then
        return text
    end
    if text == nil or text == "" then
        return short
    end
    if looks_like_generic_host_title(text) or looks_like_generic_ssh_title(text) then
        return short
    end
    return text
end

--- 标签栏展示用标题：优先显式 tab 标题（tmux 窗口名常在这里），再清理后的 pane 标题，最后退回域/占位
local function tab_label_for_display(tab)
    local pane = tab.active_pane
    local domain = (pane and pane.domain_name) or ""

    local from_tab = tab.tab_title
    if from_tab and from_tab:match("%S") then
        local cleaned = strip_wezterm_title_noise(from_tab)
        cleaned = prefer_ssh_name_when_placeholder(cleaned, domain)
        if cleaned ~= "" then
            return cleaned
        end
    end

    local from_pane = strip_wezterm_title_noise((pane and pane.title) or "")
    from_pane = prefer_ssh_name_when_placeholder(from_pane, domain)
    if from_pane ~= "" and not looks_like_generic_host_title(from_pane) and not looks_like_generic_ssh_title(from_pane) then
        return from_pane
    end

    -- tmux -CC 等：pane 标题常仍是 WezTerm，用域名片段区分多会话
    if domain ~= "" then
        local d = domain
        if d:lower():find("tmux", 1, true) then
            return "tmux · " .. d
        end
        return ssh_domain_display_name(d) or d
    end

    return from_pane ~= "" and from_pane or "·"
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
    config.tab_bar_at_bottom = true
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
        local inactive_fg = foreground
        if scheme.ansi and scheme.ansi[8] then
            inactive_fg = scheme.ansi[8]
        elseif scheme.brights and scheme.brights[1] then
            inactive_fg = scheme.brights[1]
        end
        local index_color = foreground
        if scheme.ansi and scheme.ansi[5] then
            index_color = scheme.ansi[5]
        elseif scheme.brights and scheme.brights[5] then
            index_color = scheme.brights[5]
        end

        local title = tab_label_for_display(tab)
        local intensity = tab.is_active and "Bold" or "Normal"
        local title_color = foreground
        if tab.is_active then
            title_color = "#e28a8a"
        end

        -- 分隔符 | 使用次要前景色，与序号/标题区分
        local sep_color = inactive_fg

        local parts = {}
        if tab.tab_index > 0 then
            parts[#parts + 1] = { Background = { Color = background } }
            parts[#parts + 1] = { Foreground = { Color = sep_color } }
            parts[#parts + 1] = { Text = " | " }
        end
        parts[#parts + 1] = { Background = { Color = background } }
        parts[#parts + 1] = { Foreground = { Color = index_color } }
        parts[#parts + 1] = { Text = string.format(" %d:", tab.tab_index + 1) }
        parts[#parts + 1] = { Foreground = { Color = title_color } }
        parts[#parts + 1] = { Attribute = { Intensity = intensity } }
        parts[#parts + 1] = { Text = " " .. title .. " " }

        return wezterm.format(parts)
    end)
end

return M
