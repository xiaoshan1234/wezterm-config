--------------------------------------------------------------------------------
-- Matrix Green：黑底 + 绿色主前景；ANSI 与扩展色带红/金/蓝/紫/青，避免「全绿」单调
-- 供 appearance.lua 注册到 config.color_schemes["Matrix Green"]
--------------------------------------------------------------------------------

return {
    -- 默认文字 / 背景（主色仍为绿，其它颜色主要在 ANSI 与下方扩展项）
    foreground = "#63d986",
    background = "#000000",

    cursor_bg = "#63d986",
    cursor_fg = "#000000",
    cursor_border = "#6bc78a",

    selection_fg = "#0a0f0c",
    selection_bg = "#347556",

    split = "#2a3540",

    -- IME / Leader 等待组合输入时的光标色（Palette 仅支持 compose_cursor 单字段，见官方文档）
    compose_cursor = "#9ddcb0",

    -- 8 色 ANSI：黑、红、绿、黄、蓝、洋红、青、白（程序 ls、dircolors、语法高亮等依赖）
    ansi = {
        "#121a16", -- 0 黑（极深绿灰）
        "#f07178", -- 1 红（珊瑚，错误/删除线）
        "#56d364", -- 2 绿（与主前景略区分，目录/成功）
        "#ffcb6b", -- 3 黄（琥珀，警告/关键字）
        "#82aaff", -- 4 蓝（天蓝，路径/信息）
        "#c792ea", -- 5 洋红（紫藤，类型/宏）
        "#89ddff", -- 6 青（亮青，数字/常量）
        "#a6accd", -- 7 白（偏冷灰，次要正文）
    },
    brights = {
        "#3d4d44", -- bright black
        "#ff8b92", -- bright red
        "#7ef0a0", -- bright green
        "#ffe082", -- bright yellow
        "#a8c7ff", -- bright blue
        "#ddb8ff", -- bright magenta
        "#b4f0ff", -- bright cyan
        "#d5daf0", -- bright white
    },

    -- 256 色表 16–21：混入棕、靛、金、紫、青蓝，给部分 TUI 渐变/色条用
    indexed = {
        [16] = "#2a1810",
        [17] = "#1a2840",
        [18] = "#4a3a18",
        [19] = "#1a4830",
        [20] = "#352050",
        [21] = "#1a4550",
    },

    -- 响铃时边框闪烁色（橙红，与绿字区分明显）
    visual_bell = "#e07856",

    -- QuickSelect 颜色见 appearance.lua → config.colors（须 { Color = "#..." }，见该文件注释）
}
