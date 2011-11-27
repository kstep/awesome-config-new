local sys = require('esources.sys')

local progressbar = require('awful.widget.progressbar')
local tooltip = require('awful.tooltip')

local setmetatable = setmetatable

module('widgets.battery')

local event_sources = {}
local function event_source(battery, timeout)
    if not event_sources[battery] then
        event_sources[battery] = sys {
            timeout = timeout,
            path = 'class/power_supply/' .. battery,
            fields = {
                energy_full = '*n',
                energy_now  = '*n',
                status      = '*l',
            }
        }
    end
    return event_sources[battery]
end

local status_colors = {
    Charging    = '#00FF00',
    Discharging = '#FF0000',
    Charged     = '#00FFFF',
    Unknown     = '#00FFFF',
}
local default_status_color = '#E2EEEA'

function new(battery, timeout)
    local esrc = event_source(battery, timeout)

    local widget = progressbar { width = 10 }
    local energy = 0
    widget:set_max_value(100)
    widget:set_vertical(true)

    widget.esource = esrc
    widget.update = function (esrc, value)
        energy = value.energy_now * 100 / value.energy_full
        widget:set_color(status_colors[value.status] or default_status_color)
        widget:set_value(energy)
    end

    esrc:connect_signal('value::updated', widget.update)
    esrc:update()

    widget.tooltip = tooltip {
        objects = { widget },
        timeout = timeout or 10,
        timer_function = function ()
            return ('%d%%'):format(energy)
        end
    }

    return widget
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })
