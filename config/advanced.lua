--------------------------------------------------------------------------------
-- 杂项：滚动、配置热重载、退出提示、状态刷新、SSH 后端等
--------------------------------------------------------------------------------

local M = {}

function M.apply(config)
    -- 滚动条与回滚行数上限
    config.enable_scroll_bar = true
    config.scrollback_lines = 20000

    -- 保存配置后自动重载，无需重启 WezTerm
    config.automatically_reload_config = true

    -- 子进程干净退出时关闭窗口；Verbose 在退出时输出较详细日志
    config.exit_behavior = "CloseOnCleanExit"
    config.exit_behavior_messaging = "Verbose"

    -- 状态栏等内容刷新间隔（毫秒）
    config.status_update_interval = 50000

    -- Wayland 前端（主要影响 Linux）；Windows 上一般无实质作用，显式关闭即可
    config.enable_wayland = false

    -- SSH 子进程后端：Ssh2 对交互式密码认证等场景兼容更好
    config.ssh_backend = "Ssh2"
end

return M
