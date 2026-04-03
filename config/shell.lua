local utils = require("config.utils")

local M = {}

function M.apply(config)
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
