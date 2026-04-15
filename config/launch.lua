--------------------------------------------------------------------------------
-- 启动菜单：自动从 wsl_domains / ssh_domains / exec_domains 生成「走某域」的项
-- WSL：未单独配置 wsl_domains 时用 wezterm.default_wsl_domains()（解析 wsl -l -v）
-- SpawnCommand 的 domain：https://wezterm.org/config/lua/SpawnCommand.html
-- default_wsl_domains：https://wezterm.org/config/lua/wezterm/default_wsl_domains.html
--------------------------------------------------------------------------------

local wezterm = require("wezterm")
local utils = require("config.utils")
local exec_domains = require("config.exec_domains")

local M = {}

function M.apply(config)
    local launch_menu = {
          { label = "bash",           args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" } },
          { label = "powerShell",     args = { "powershell.exe", "-NoLogo" } },
          { label = "cmd",            args = { "cmd.exe"} },
    }

    -- Windows：注册 WSL 域（与官方默认一致，name 形如 WSL:debian），并写入启动菜单
    if utils.is_windows() then
        if not config.wsl_domains or #config.wsl_domains == 0 then
            local ok, domains = pcall(wezterm.default_wsl_domains)
            if ok and domains then
                config.wsl_domains = domains
            else
                config.wsl_domains = {}
            end
        end
        for _, w in ipairs(config.wsl_domains or {}) do
            local label = w.name or ("WSL:" .. (w.distribution or "?"))
            table.insert(launch_menu, {
                label = "🐧 " .. label,
                domain = { DomainName = w.name },
            })
        end
    end

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
