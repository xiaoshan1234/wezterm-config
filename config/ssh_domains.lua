--------------------------------------------------------------------------------
-- SSH 域：WezTerm 内置多路连接；multiplexing 使用远端 wezterm 时可会话恢复
--------------------------------------------------------------------------------

local M = {}

function M.apply(config)
    config.ssh_domains = {
        {
            name = '10.18.0.20',
            remote_address = '10.18.0.20',
            username = 'liuhao',
            -- 使用远端 WezTerm 多路复用：断线重连、图形区会话等（需远端已安装对应路径）
            multiplexing = 'None',
            -- connect_automatically = true,
        },
        {
            name = '10.18.0.25',
            remote_address = '10.18.0.25',
            username = 'liuhao',
            multiplexing = 'None',
            -- connect_automatically = true,
        },
        {
            name = 'xp',
            remote_address = 'xp.xiaoshan12138.top',
            username = 'loner',
            multiplexing = 'None',
            -- connect_automatically = true,
        },
    }
end

return M
