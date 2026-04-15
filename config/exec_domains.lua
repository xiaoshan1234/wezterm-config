--------------------------------------------------------------------------------
-- ExecDomain：在本机起进程前用 fixup 包一层命令（WSL / systemd 等）
-- 文档：https://wezterm.org/config/lua/ExecDomain.html
-- EXEC_DOMAIN_SPECS 供 config.launch 生成启动菜单项（与域 name 一致）
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

---@type table[] name / label / fixup；可选 when = function(): boolean
M.EXEC_DOMAIN_SPECS = {
    {
        name = "tmux-diag-cmd-nb",
        label = "🔌 10.18.0.20 · tmux -CC diag-cmd-nb",
        fixup = function(cmd)
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
        end,
    },
}

function M.apply(config)
    local domains = {}
    for _, spec in ipairs(M.EXEC_DOMAIN_SPECS) do
        if spec.when == nil or spec.when() then
            table.insert(domains, wezterm.exec_domain(spec.name, spec.fixup, spec.label))
        end
    end
    config.exec_domains = domains

    -- 若希望默认新标签即进某 ExecDomain，取消下一行注释并改成域 name：
    -- config.default_domain = "tmux-diag-cmd-nb"
end

return M
