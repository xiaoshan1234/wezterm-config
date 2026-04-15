--------------------------------------------------------------------------------
-- 动态/定时背景图：从目录选图、随机或固定、按间隔轮换
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local constants = require("config.constants")

local M = {}

-- enabled：总开关；random：随机选图否则用 fixed_image
-- interval_minutes：轮换间隔；image_hsb：背景图色相/饱和度/亮度微调
local options = {
    enabled = true,
    random = false,
    fixed_image = "03.jpg",
    interval_minutes = 5,
    image_dir = constants.CONFIG_DIR .. "/images",
    image_hsb = {
        brightness = 0.08,
        hue = 1.0,
        saturation = 1.0,
    },
}

local image_pool = nil
local last_switch_time = 0
local last_image = nil

--- 按扩展名判断是否为支持的图片
local function is_image_file(path)
    local lower = path:lower()
    return lower:match("%.png$")
        or lower:match("%.jpg$")
        or lower:match("%.jpeg$")
        or lower:match("%.webp$")
        or lower:match("%.gif$")
end

--- 扫描 image_dir，缓存为 image_pool（仅首次或失败后重试）
local function load_images()
    if image_pool and #image_pool > 0 then
        return image_pool
    end

    local ok, entries = pcall(wezterm.read_dir, options.image_dir)
    if not ok or not entries then
        wezterm.log_warn("Failed to read images directory: " .. options.image_dir)
        image_pool = nil
        return {}
    end

    local images = {}
    for _, entry in ipairs(entries) do
        if is_image_file(entry) then
            table.insert(images, entry)
        end
    end

    image_pool = images
    return image_pool
end

--- 非随机模式：使用固定文件名（相对 image_dir）
local function resolve_fixed_image()
    if not options.fixed_image or options.fixed_image == "" then
        return nil
    end

    return options.image_dir .. "/" .. options.fixed_image
end

--- 随机模式：从目录中选一张；无可用图时退回上次或固定图
local function pick_random_image()
    local images = load_images()
    if #images == 0 then
        return last_image or (resolve_fixed_image and resolve_fixed_image())
    end

    local index = math.random(#images)
    return images[index]
end

local function pick_image()
    if not options.enabled then
        return nil
    end

    if options.random then
        return pick_random_image()
    end

    return resolve_fixed_image()
end

--- 将当前窗口的背景图与 HSB 写入 overrides
local function apply_image(window, image)
    if not image then
        return
    end

    last_image = image

    local overrides = window:get_config_overrides() or {}
    overrides.window_background_image = image
    overrides.window_background_image_hsb = options.image_hsb
    window:set_config_overrides(overrides)
end

--- 到达轮换间隔时换一张（依赖 status 刷新触发）
local function maybe_rotate(window)
    if not options.enabled then
        return
    end

    local interval_seconds = options.interval_minutes * 60
    local now = os.time()
    if now - last_switch_time < interval_seconds then
        return
    end

    last_switch_time = now
    apply_image(window, pick_image())
end

function M.apply(config)
    if not options.enabled then
        return
    end

    local initial = pick_image()
    if initial then
        config.window_background_image = initial
        config.window_background_image_hsb = options.image_hsb
    end

    -- 与轮换间隔对齐，让 update-status 以合适频率触发 maybe_rotate
    config.status_update_interval = options.interval_minutes * 60 * 1000

    wezterm.on("update-status", function(window, _pane)
        maybe_rotate(window)
    end)
end

return M
