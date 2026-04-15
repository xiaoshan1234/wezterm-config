--------------------------------------------------------------------------------
-- 启动菜单：固定项 + 自动从 ssh_domains / exec_domains 规格生成「走某域」的项
-- SpawnCommand 的 domain 见：https://wezterm.org/config/lua/SpawnCommand.html
-- （与 keybindings 里 Leader+p / Leader+Space 等关联）
--------------------------------------------------------------------------------

local utils = require("config.utils")
local exec_domains = require("config.exec_domains")

local M = {}

function M.apply(config)
    local launch_menu = {}

    -- 与 config.ssh_domains 同步（需在 wezterm.lua 中先于本模块应用 ssh_domains）
    for _, d in ipairs(config.ssh_domains or {}) do
        local host = d.name or d.remote_address or "?"
        table.insert(launch_menu, {
            label = "🔗 SSH · " .. host,
            domain = { DomainName = d.name },
        })
    end

    -- 与 exec_domains.lua 中 EXEC_DOMAIN_SPECS 同步（仅注册了的域才进菜单）
    for _, spec in ipairs(exec_domains.EXEC_DOMAIN_SPECS) do
        if spec.when == nil or spec.when() then
            table.insert(launch_menu, {
                label = "⚙ " .. spec.label,
                domain = { DomainName = spec.name },
            })
        end
    end

    config.launch_menu = launch_menu

    if utils.is_windows() then
        if utils.windows_command_exists("powershell") then
            config.default_prog = { "powershell", "-NoLogo" }
        else
            config.default_prog = { "cmd.exe" }
        end
    else
        if utils.unix_command_exists("zsh") then
            config.default_prog = { "zsh", "-i" }
        else
            config.default_prog = { "bash", "-i" }
        end
    end
end

return M
