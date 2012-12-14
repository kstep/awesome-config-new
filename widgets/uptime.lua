local textbox = require('wibox.widget.textbox')
local wutil = require('widgets.util')
local timer = timer
local io = io
local setmetatable = setmetatable

local uptime = { mt = {} }

local function readfile(file, format)
    local fh = io.open(file, 'r')
    if fh then
        local result = fh:read(format or '*a')
        fh:close()
        return result
    end
end

function uptime.new()
    local widget = textbox()
    widget.update = function (self)
        local uptime = readfile('/proc/uptime', '*n')
        if uptime then
            local d, h, m, s = wutil.dhms(uptime)
            self:set_text((' [%dd %02d:%02d]'):format(d, h, m))
        end
    end
    widget:update()

    widget.timer = timer { timeout = 60 }
    widget.timer:connect_signal('timeout', function () widget:update() end)
    widget.timer:start()

    return widget
end

function uptime.mt:__call(...)
    return uptime.new(...)
end

return setmetatable(uptime, uptime.mt)

