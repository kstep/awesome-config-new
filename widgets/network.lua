local sys = require('esources.sys')
local wutil = require('widgets.util')

local tooltip = require('awful.tooltip')
local graph = require('awful.widget.graph')
local util = require('awful.util')
local textbox = require('wibox.widget.textbox')
local layout = require('wibox.layout')
local tooltip = require('awful.tooltip')
local os = os

local setmetatable = setmetatable

module('widgets.network')

local event_sources = {}
local function event_source(interface, timeout)
    if not event_sources[interface] then
        event_sources[interface] = sys {
            timeout = timeout,
            path = 'class/net/' .. interface,
            fields = {
                operstate = '*l',
                ['statistics/rx_bytes'] = '*n',
                ['statistics/tx_bytes'] = '*n',
            }
        }
    end
    return event_sources[interface]
end

local state_colors = {
    up   = '#00ff00',
    down = '#ff0000',
}
local default_state_color = '#ffff00'

function new(interface, timeout)
    local widget = layout.fixed.horizontal()

    local label = textbox()
    local pattern = '<span color="%s"> ' .. interface .. ' (%d %s/s) </span>'
    label:set_text(interface)
    widget:add(label)

    local chart = graph { width = 30 }
    widget:add(chart)

    local max_rx_bytes = 1
    local timestamp = os.time()
    widget.update = function (esrc, value, old_value)

        if not value.operstate then return end

        local rx_bytes = ((value['statistics/rx_bytes'] or 0) - (old_value['statistics/rx_bytes'] or 0))
        if rx_bytes > max_rx_bytes then max_rx_bytes = rx_bytes end
        chart:add_value(rx_bytes / max_rx_bytes, 0)

        local rx_unit = {0, 'b'}
        local now = os.time()
        local delta = now - timestamp
        timestamp = now

        if delta > 0 then
            rx_unit = wutil.humanize(rx_bytes / delta)
        end

        label:set_markup(pattern:format(state_colors[value.operstate] or default_state_color, rx_unit[1], rx_unit[2]))
    end

    widget.tooltip = tooltip {
        objects = { widget },
        timeout = timeout or 10,
        timer_function = function ()
            local result = util.pread('ifconfig ' .. interface) or 'Not connected.'
            return util.escape(result)
        end
    }

    widget.esource = event_source(interface, timeout)
    widget.esource:connect_signal('value::updated', widget.update)
    widget.esource:update()

    return widget
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })

