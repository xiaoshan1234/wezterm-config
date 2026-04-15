--------------------------------------------------------------------------------
-- 工具函数：跨平台检测命令是否存在、判断是否为 Windows
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

--- 检查 Windows 下命令是否在 PATH 中（依赖 `where`）
---@param cmd string 命令名称
---@return boolean
function M.windows_command_exists(cmd)
    local success, stdout = wezterm.run_child_process({ "where", cmd })
    return success and stdout and stdout ~= ""
end

--- 检查 Unix 下命令是否在 PATH 中（依赖 `command -v`）
---@param cmd string 命令名称
---@return boolean
function M.unix_command_exists(cmd)
    local success, stdout = wezterm.run_child_process({ "sh", "-c", "command -v " .. cmd })
    return success and stdout and stdout ~= ""
end

--- 根据 target_triple 判断当前是否为 Windows 构建
---@return boolean
function M.is_windows()
    return wezterm.target_triple:find("windows") ~= nil
end

return M
