module('widgets.util')

function hms(value)
    local secs = value or 0
    local days  = math.floor(secs / 86400); secs = secs % 86400
    local hours = math.floor(secs / 3600); secs = secs % 3600
    local mins  = math.floor(secs / 60); secs = secs % 60
    return { days, hours, mins, secs }
end

function humanize(value, meta)
    meta = meta or {}
    local suffixes = meta.suffixes or { "b", "K", "M", "G", "T", "P", "E", "Z", "Y" }
    local scale = meta.scale or 1024
    local init = meta.init or 1

    local suffix = init
    while value > scale and suffix < #suffixes do
        value = value / scale
        suffix = suffix + 1
    end
    return { value, suffixes[suffix] }
end
