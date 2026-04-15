--------------------------------------------------------------------------------
-- ExecDomain：在本机起进程前用 fixup 包一层命令（WSL / systemd 等）
-- 文档：https://wezterm.org/config/lua/ExecDomain.html
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local utils = require("config.utils")

local M = {}

local function basename(s)
    return (string.gsub(s, "(.*[/\\])(.*)", "%2"))
end

function M.apply(config)
    local domains = {}

    -- 本机起 ssh：连上即 tmux -CC attach（不走 ssh_domains；需 PATH 中有 ssh）
    table.insert(
        domains,
        wezterm.exec_domain("tmux-diag-cmd-nb", function(cmd)
            cmd.args = {
                "ssh",
                "-t",
                "liuhao@10.18.0.20",
                "--",
                "tmux",
                "-CC",
                "attach",
                "-t",
                "diag-cmd-nb",
            }
            return cmd
        end, "🔌 10.18.0.20 · tmux -CC diag-cmd-nb")
    )

    config.exec_domains = domains

    -- 若希望默认新标签即进某 ExecDomain，取消下一行注释并改成域 name：
    -- config.default_domain = "wsl-debian"
end

return M
