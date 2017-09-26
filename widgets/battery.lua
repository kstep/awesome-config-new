local sys = require('esources.sys')
local wutil = require('widgets.util')

local util = require('awful.util')
local wibox = require('wibox')
local tooltip = require('awful.tooltip')
local theme = require('beautiful')
local rotate = require("wibox.container.rotate")

local setmetatable = setmetatable

local battery = { mt = {} }

local event_sources = {}
local function event_source(battery, timeout)
    if not event_sources[battery] then
        event_sources[battery] = sys {
            timeout = timeout,
            path = 'class/power_supply/' .. battery,
            fields = {
                charge_full = '*n',
                charge_now  = '*n',
                energy_full = '*n',
                energy_now  = '*n',
                status      = '*l',
            }
        }
    end
    return event_sources[battery]
end

local status_colors = {
    Charging    = theme.colors.green,
    Discharging = theme.colors.red,
    Charged     = theme.colors.blue,
    Unknown     = theme.colors.orange,
}
local default_status_color = theme.colors.orange

function battery.new(battery, timeout)
    local esrc = event_source(battery, timeout)

    local widget = wibox.widget {
        {
            max_value = 100,
            widget = wibox.widget.progressbar,
            value = 0
        },
        forced_width = 10,
        layout = wibox.container.rotate,
        direction = 'east',
    }
    
    local energy = 0

    widget.esource = esrc
    widget.update = function (esrc, value)
        energy = (value.charge_now or value.energy_now or 1) * 100 / (value.charge_full or value.energy_full or 1)
        widget.color = status_colors[value.status] or default_status_color
        widget.value = energy
    end

    esrc:connect_signal('value::updated', widget.update)
    esrc:update()

    local tooltip_cmd = 'acpi -b'
    widget.tooltip = tooltip {
        objects = { widget },
        timeout = timeout or 10,
        timer_function = function ()
            local result = wutil.rtrim(wutil.pread(tooltip_cmd))
            return util.escape(result)
        end
    }

    return widget
end

function battery.mt:__call(...)
    return battery.new(...)
end

return setmetatable(battery, battery.mt)

