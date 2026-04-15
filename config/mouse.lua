--------------------------------------------------------------------------------
-- 鼠标：在默认绑定基础上追加选区复制、拖窗、Ctrl+点击打开链接
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    local act = wezterm.action

    -- 保留 WezTerm 自带鼠标行为，再叠加 mouse_bindings
    config.disable_default_mouse_bindings = false

    config.mouse_bindings = {
        -- 左键释放：将选区复制到剪贴板（与 CompleteSelection 语义一致）
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "NONE",
            action = act.CompleteSelection("Clipboard"),
        },
        -- 右键：弹出快捷菜单（WezTerm 无原生桌面右键菜单，用 InputSelector 模拟）
        -- {
        --     event = { Down = { streak = 1, button = "Right" } },
        --     mods = "NONE",
        --     action = wezterm.action_callback(function(window, pane)
        --         window:perform_action(
        --             act.InputSelector({
        --                 title = "快捷菜单",
        --                 choices = {
        --                     { label = "SSH / 域连接", id = "ssh" },
        --                     { label = "启动菜单", id = "launch" },
        --                     { label = "粘贴", id = "paste" },
        --                     { label = "复制选区到剪贴板", id = "copy" },
        --                     { label = "搜索…", id = "search" },
        --                     { label = "复制模式", id = "copy_mode" },
        --                     { label = "清除滚动历史", id = "clear_scrollback" },
        --                 },
        --                 action = wezterm.action_callback(function(win, p, id, _label)
        --                     if not id then
        --                         return
        --                     end
        --                     local a
        --                     if id == "ssh" then
        --                         a = act.ShowLauncherArgs({
        --                             title = "SSH 连接",
        --                             flags = "FUZZY|DOMAINS",
        --                         })
        --                     elseif id == "launch" then
        --                         a = act.ShowLauncherArgs({
        --                             title = "启动菜单",
        --                             flags = "FUZZY|LAUNCH_MENU_ITEMS",
        --                         })
        --                     elseif id == "paste" then
        --                         a = act.PasteFrom("Clipboard")
        --                     elseif id == "copy" then
        --                         a = act.CopyTo("Clipboard")
        --                     elseif id == "search" then
        --                         a = act.Search("CurrentSelectionOrEmptyString")
        --                     elseif id == "copy_mode" then
        --                         a = act.ActivateCopyMode
        --                     elseif id == "clear_scrollback" then
        --                         a = act.ClearScrollback("ScrollbackAndViewport")
        --                     end
        --                     if a then
        --                         win:perform_action(a, p)
        --                     end
        --                 end),
        --             }),
        --             pane
        --         )
        --     end),
        -- },
        -- Ctrl+Alt+左键拖动：移动窗口
        {
            event = { Drag = { streak = 1, button = "Left" } },
            mods = "CTRL|ALT",
            action = act.StartWindowDrag,
        },
        -- Ctrl+左键释放：在光标处打开超链接
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "CTRL",
            action = act.OpenLinkAtMouseCursor,
        },
    }
end

return M
