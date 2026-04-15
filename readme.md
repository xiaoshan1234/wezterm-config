# WezTerm 配置说明

## Domains（域）是什么

在 WezTerm 里，**Domain** 描述「**这个窗格里的进程在哪里、以什么方式被拉起**」。新建标签、分屏、启动器里选「域」时，本质是在选 **SpawnCommand** 要用的执行环境，而不是改键名或随便起的别名。

常见类型（官方文档里会分别说明）：

| 概念 | 作用简述 |
|------|-----------|
| **本机默认** | 未指定域时，用本机 `default_prog` 等配置起 shell，等价于「当前本机域」。 |
| **SSH Domain** | 通过 SSH 连到远端；可选远端 **WezTerm** 多路复用（会话恢复等）或 **None**（普通 SSH shell）。 |
| **Exec Domain** | 仍在本机起进程，但在真正 `exec` 前用 **fixup** 把命令包一层（例如包进 `wsl.exe`、`systemd-run`）。 |
| **Unix Domain** | 本机 Unix 套接字上的 **wezterm** 多路服务（多窗格共享一个服务端）。 |
| **WSL Domain** | Windows 上连 WSL 里跑的 WezTerm 多路实例（与「用 exec 包一层 wsl」是不同机制）。 |
| **TLS Client** | 经 TLS 连到远端的 WezTerm 网关。 |

配置里对应字段大致是：`ssh_domains`、`exec_domains`、`unix_domains`、`wsl_domains`、`tls_clients_server`、`tls_clients_client`，以及 **`default_domain`**（字符串，设为某个已注册域的 `name` 后，新标签默认走该域）。

**注意**：`multiplexing` 只能是 **`WezTerm`** 或 **`None`**，不能写成 `tmux`。本仓库的 SSH 示例见 `config/ssh_domains.lua`。

## 本仓库中的 Domains

- **`config/ssh_domains.lua`** → `config.ssh_domains`：预置的 SSH 连接（名称即 `name`，在启动器里会出现在域列表中）。
- **`config/exec_domains.lua`** → `config.exec_domains`：用 `wezterm.exec_domain(...)` 注册的自定义域。当前在 **Windows** 上提供 **`wsl-debian`**（与 `launch.lua` 里 `wsl.exe -d debian` 一致）；在 **Linux** 上提供 **`scoped`**（`systemd-run --user --scope`，需 systemd user 环境）。若希望新标签默认走某 ExecDomain，可在该文件末尾取消注释并设置 `config.default_domain`。

## 怎么用

- 在绑定了 **`DOMAINS`** 的启动器（例如 Leader+Space）里选择对应域或 SSH 项。
- 在动作里写 **`SpawnCommand`** / **`SpawnTab`** 时传入 `domain = { Domain = "域名称" }` 或 `domain = "CurrentPaneDomain"` 等，与官方 `SpawnCommand` 文档一致。

更多细节见官方说明：[ExecDomain](https://wezterm.org/config/lua/ExecDomain.html)、[SSH Domains](https://wezterm.org/config/lua/SSH.html)、[SpawnCommand](https://wezterm.org/config/lua/pane/SpawnCommand.html)。
