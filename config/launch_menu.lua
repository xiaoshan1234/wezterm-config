--------------------------------------------------------------------------------
-- 启动菜单项：Launcher 中「新建标签」可选的 shell / WSL / SSH 等预设
-- （与 keybindings 里 Leader+p / Leader+Space 等关联）
--------------------------------------------------------------------------------

local M = {}

function M.apply(config)
    config.launch_menu = {
        -- Shell
        { label = "bash",           args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" } },
        { label = "powerShell",     args = { "powershell.exe", "-NoLogo" } },

        -- WSL 发行版
        { label = "debian",    args = { "wsl.exe", "-d", "debian" } },

        -- SSH 连接
        { label = "10.18.0.20", args = { "ssh", "liuhao@10.18.0.20" } },
    }
end

return M
