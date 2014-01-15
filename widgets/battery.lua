local sys = require('esources.sys')
local wutil = require('widgets.util')

local util = require('awful.util')
local progressbar = require('awful.widget.progressbar')
local tooltip = require('awful.tooltip')
local theme = require('beautiful')

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

    local widget = progressbar { width = 10 }
    local energy = 0
    widget:set_max_value(100)
    widget:set_vertical(true)

    widget.esource = esrc
    widget.update = function (esrc, value)
        energy = (value.charge_now or value.energy_now) * 100 / (value.charge_full or value.energy_full)
        widget:set_color(status_colors[value.status] or default_status_color)
        widget:set_value(energy)
    end

    esrc:connect_signal('value::updated', widget.update)
    esrc:update()

    local tooltip_cmd = 'acpi -b'
    widget.tooltip = tooltip {
        objects = { widget },
        timeout = timeout or 10,
        timer_function = function ()
            local result = wutil.rtrim(util.pread(tooltip_cmd))
            return util.escape(result)
        end
    }

    return widget
end

function battery.mt:__call(...)
    return battery.new(...)
end

return setmetatable(battery, battery.mt)

