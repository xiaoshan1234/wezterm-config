local wezterm = require("wezterm")

local constants = require("config.constants")

local M = {}

function M.apply(config)
    local act = wezterm.action

    -- 禁用默认快捷键
    config.disable_default_key_bindings = true

    -- Leader 键
    config.leader = {
        key = "a",
        mods = "CTRL",
        timeout_milliseconds = 1500,
    }

    -- 构建配色方案选择器的选项
    local color_scheme_choices = {}
    for _, scheme in ipairs(constants.COLOR_SCHEMES) do
        table.insert(color_scheme_choices, { label = scheme })
    end

    config.keys = {
        -- ========== 窗口管理 ==========
        { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
        { key = "m", mods = "LEADER", action = act.Hide },

        -- ========== 标签页管理 ==========
        { key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
        { key = "w", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
        { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
        { key = "t", mods = "LEADER", action = act.EmitEvent("toggle-tab-bar") },

        -- ========== 窗格分割 ==========
        { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

        -- ========== 窗格导航 (Leader + 方向键) ==========
        { key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
        { key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
        { key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
        { key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

        -- ========== 窗格大小调整 (Ctrl+Shift + 方向键) ==========
        { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
        { key = "DownArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
        { key = "UpArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
        { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

        -- ========== 窗格关闭 ==========
        { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

        -- ========== 搜索与命令 ==========
        { key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },
        {
            key = "p",
            mods = "LEADER",
            action = act.ShowLauncherArgs({
                title = "🚀 启动菜单",
                flags = "FUZZY|LAUNCH_MENU_ITEMS",
            }),
        },
        { key = "k", mods = "LEADER", action = act.ClearScrollback("ScrollbackAndViewport") },
        {
            key = "Space",
            mods = "LEADER",
            action = act.ShowLauncherArgs({
                flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|KEY_ASSIGNMENTS",
            }),
        },

        -- ========== 滚动 ==========
        { key = "Home", mods = "LEADER", action = act.ScrollToTop },
        { key = "End", mods = "LEADER", action = act.ScrollToBottom },

        -- ========== 复制模式（类似 Vim 的键盘选择模式）==========
        { key = "c", mods = "LEADER", action = act.ActivateCopyMode },

        -- ========== 配色方案切换 (Leader+s) ==========
        {
            key = "s",
            mods = "LEADER",
            action = act.InputSelector({
                title = "🎨 选择配色方案",
                choices = color_scheme_choices,
                action = wezterm.action_callback(function(window, _pane, _id, label)
                    if label then
                        window:set_config_overrides({ color_scheme = label })
                        wezterm.log_info("配色方案已切换为: " .. label)
                    end
                end),
            }),
        },

        -- ========== SSH 域连接 (Leader+o) ==========
        {
            key = "o",
            mods = "LEADER",
            action = act.ShowLauncherArgs({
                title = "🔗 SSH 连接",
                flags = "FUZZY|DOMAINS",
            }),
        },

        -- ========== 远程粘贴（发送剪贴板内容到远程 Vim/Helix）==========
        -- Leader+v: 使用 Bracketed Paste 模式粘贴（适用于支持该模式的编辑器）
        {
            key = "v",
            mods = "LEADER",
            action = act.PasteFrom("Clipboard"),
        },
        -- Ctrl+Shift+V: 直接发送剪贴板文本（SendString 模式，适用于所有终端程序）
        {
            key = "V",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(window, pane)
                -- 获取剪贴板内容并直接发送到终端
                local clipboard = window:copy_clipboard("Clipboard")
                if clipboard then
                    pane:send_text(clipboard)
                end
            end),
        },
    }
end

return M
