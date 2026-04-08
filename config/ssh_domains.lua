local M = {}

function M.apply(config)
    config.ssh_domains = {
        {
            name = '10.18.0.20',
            remote_address = '10.18.0.20',
            username = 'liuhao',
            multiplexing = 'WezTerm',-- 关键：启用 WezTerm 多路复用（断网重连、会话持久）
            remote_wezterm_path = '/home/liuhao/wezterm/usr/bin/wezterm',
            -- connect_automatically = true,
        },
        {
            name = '10.18.0.25',
            remote_address = '10.18.0.25',
            username = 'liuhao',
            multiplexing = 'WezTerm',-- 关键：启用 WezTerm 多路复用（断网重连、会话持久）
            remote_wezterm_path = '/home/liuhao/wezterm/usr/bin/wezterm',
            -- connect_automatically = true,
        },
        {
            name = 'xp',
            remote_address = 'xp.xiaoshan12138.top',
            username = 'loner',
            multiplexing = 'WezTerm',-- 关键：启用 WezTerm 多路复用（断网重连、会话持久）
            -- connect_automatically = true,
        },
    }
end

return M
