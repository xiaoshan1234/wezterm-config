local M = {}

function M.apply(config)
    config.ssh_domains = {
        {
            name = "mint",
            remote_address = "122.207.79.207:22",
            username = "mint",
            -- 如果需要可以指定私钥路径
            -- ssh_option = { identityfile = "~/.ssh/id_rsa" },
        },
        {
            name = "linuxbrew",
            remote_address = "122.207.79.207:22",
            username = "linuxbrew",
        },
        {
            name = "software",
            remote_address = "122.207.79.207:22",
            username = "software",
        },
    }
end

return M
