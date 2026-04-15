--------------------------------------------------------------------------------
-- 键盘：禁用默认键、Leader、窗口/标签/分屏/搜索/配色/SSH 等自定义绑定
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local constants = require("config.constants")

local M = {}

function M.apply(config)
    local act = wezterm.action

    -- 全部改用下方 keys，避免与默认快捷键冲突或重复
    config.disable_default_key_bindings = true

    -- Leader：先按 Ctrl+a，再在超时时间内按第二个键
    config.leader = {
        key = "a",
        mods = "CTRL",
        timeout_milliseconds = 1500,
    }

    -- 与 constants.COLOR_SCHEMES 对应的下拉选项（仅 label，选中名即 color_scheme）
    local color_scheme_choices = {}
    for _, scheme in ipairs(constants.COLOR_SCHEMES) do
        table.insert(color_scheme_choices, { label = scheme })
    end

    config.keys = {
        -- ========== 窗口管理 ==========
        { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
        { key = "m", mods = "LEADER", action = act.Hide },

        -- ========== 标签页管理 ==========
        { key = "n", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
        { key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
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
        {
            key = "R",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(window, pane)
              -- 断开当前 SSH/域连接后重新挂到同一域（用于会话恢复场景）
              pane:disconnect()
              local domain = window:active_tab():get_domain()
              window:perform_action(wezterm.action.AttachDomain(domain.name), pane)
            end),
          },
        -- ========== 搜索与命令 ==========
        { key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
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

        -- ========== 剪贴板 ==========
        { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") },
        { key = "Delete", mods = "SHIFT", action = act.CopyTo("Clipboard") },

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
                local clipboard = window:copy_clipboard("Clipboard")
                if clipboard then
                    pane:send_text(clipboard)
                end
            end),
        },
    }
end

return M
