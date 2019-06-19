local naughty = require("naughty")

local math = math
local io = io

local util = { mt = {} }

function util.dhms(value)
    local secs = value or 0
    local days  = math.floor(secs / 86400); secs = secs % 86400
    local hours = math.floor(secs / 3600); secs = secs % 3600
    local mins  = math.floor(secs / 60); secs = secs % 60
    return days, hours, mins, secs
end

function util.humanize(value, meta)
    meta = meta or {}
    local suffixes = meta.suffixes or { "b", "K", "M", "G", "T", "P", "E", "Z", "Y" }
    local scale = meta.scale or 1024
    local init = meta.init or 1

    local suffix = init
    while value > scale and suffix < #suffixes do
        value = value / scale
        suffix = suffix + 1
    end
    return value, suffixes[suffix]
end

function util.rtrim(value)
    return value:gsub('%s+$', '')
end

function util.ltrim(value)
    return value:gsub('^%s+', '')
end

function util.trim(value)
    return util.rtril(util.ltrim(value))
end

function util.pread(command)
    local out = io.popen(command)
    local result = out:read("*a")
    out:close()
    return result
end

local level_notification
function util.show_level_notification(title, percent, icon, text)
    local barsize = math.floor(percent / 10)
    local bar = ("▣"):rep(barsize) .. ("□"):rep(10 - barsize)

    if level_notification then
        naughty.destroy(level_notification)
    end

    level_notification = naughty.notify {
        title = title .. (text or (percent .. "%")),
        text = bar,
        timeout = 5,
        icon = icon,
        screen = mouse.screen,
    }
end

return util

