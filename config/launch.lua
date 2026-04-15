--------------------------------------------------------------------------------
-- 启动菜单项：Launcher 中「新建标签」可选的 shell / WSL / SSH 等预设
-- （与 keybindings 里 Leader+p / Leader+Space 等关联）
--------------------------------------------------------------------------------

local utils = require("config.utils")

local M = {}

function M.apply(config)
    -- 启动菜单项
    config.launch_menu = {
        -- Shell
        { label = "bash",           args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" } },
        { label = "powerShell",     args = { "powershell.exe", "-NoLogo" } },

        -- WSL 发行版
        { label = "debian",    args = { "wsl.exe", "-d", "debian" } },

        -- SSH 连接
        { label = "10.18.0.20", args = { "ssh", "liuhao@10.18.0.20" } },
    }

    -- 设置默认程序
    if utils.is_windows() then
        if utils.windows_command_exists("powershell") then
            config.default_prog = { "powershell", "-NoLogo" }
        else
            config.default_prog = { "cmd.exe" }
        end
    else
        -- Unix 系统：zsh → bash
        if utils.unix_command_exists("zsh") then
            config.default_prog = { "zsh", "-i" }
        else
            config.default_prog = { "bash", "-i" }
        end
    end
end

return M
