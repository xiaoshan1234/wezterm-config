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
