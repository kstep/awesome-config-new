local sys = require('esources.sys')
local wutil = require('widgets.util')

local tooltip = require('awful.tooltip')
local graph = require('awful.widget.graph')
local progressbar = require('awful.widget.progressbar')
local util = require('awful.util')
local textbox = require('wibox.widget.textbox')
local layout = require('wibox.layout')
local tooltip = require('awful.tooltip')
local theme = require('beautiful')
local os = os

local setmetatable = setmetatable

local network = { mt = {} }

local event_sources = {}
local function event_source(interface, timeout)
    if not event_sources[interface] then
        local fields = {
            operstate = '*l',
            ['statistics/rx_bytes'] = '*n',
            ['statistics/tx_bytes'] = '*n',
        }

        --fields['wireless/link'] = '*n'

        esrc = sys {
            timeout = timeout,
            path = 'class/net/' .. interface,
            fields = fields
        }
        --esrc.wireless = not not fields['wireless/link']

        event_sources[interface] = esrc
    end
    return event_sources[interface]
end

local state_colors = {
    up   = theme.colors.green,
    down = theme.colors.red,
}
local default_state_color = theme.colors.orange

function network.new(interface, timeout)
    local widget = layout.fixed.horizontal()
    local esrc = event_source(interface, timeout)

    local label = textbox()
    local pattern = '<span color="%s"> ' .. interface .. ' (%d %s/s) </span>'
    label:set_markup(pattern:format(default_state_color, 0, 'b'))
    widget:add(label)

    local pbar
    if esrc.wireless then
       pbar = progressbar { width = 8 }
       pbar:set_max_value(70)
       pbar:set_color("linear:0,0:20,20:0," .. theme.colors.red .. ":1," .. theme.colors.green)
       widget:add(pbar)
    end

    local chart = graph { width = 30 }
    widget:add(chart)

    local max_rx_bytes = 15*1024*1024
    local timestamp = os.time()
    widget.update = function (esrc, value, old_value)

        if not value.operstate then return end

        local rx_bytes = ((value['statistics/rx_bytes'] or 0) - (old_value['statistics/rx_bytes'] or 0))
        if rx_bytes < 0 then rx_bytes = 0 end

        local rx_speed = 0
        local rx_unit = 'b'
        local now = os.time()
        local delta = now - timestamp
        timestamp = now

        if delta > 0 then
            rx_speed, rx_unit = wutil.humanize(rx_bytes / delta)
        end

        label:set_markup(pattern:format(state_colors[value.operstate] or default_state_color, rx_speed, rx_unit))

        chart:add_value(rx_bytes / max_rx_bytes, 0)

        if pbar then
            pbar:set_value(value['wireless/link'] or 0)
        end
    end

    local tooltip_cmd = 'ifconfig ' .. interface
    if pbar then tooltip_cmd = tooltip_cmd .. ' && iwconfig ' .. interface end
    widget.tooltip = tooltip {
        objects = { widget },
        timeout = timeout or 10,
        timer_function = function ()
            local result = wutil.rtrim(util.pread(tooltip_cmd) or 'Not connected.')
            return util.escape(result)
        end
    }

    widget.esource = esrc
    widget.esource:connect_signal('value::updated', widget.update)
    widget.esource:update()

    return widget
end

function network.mt:__call(...)
    return network.new(...)
end

return setmetatable(network, network.mt)

