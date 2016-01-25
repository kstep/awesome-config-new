
local dbus = dbus
local textbox = require('wibox.widget.textbox')
local bg = require('wibox.widget.background')
local theme = require('beautiful')
local util = require('awful.util')
local button = require('awful.button')

local setmetatable = setmetatable

local kbdd = { mt = {} }

local layouts = { [0] = ' En ', [1] = ' Ru ', [2] = ' De ' }
local colors = { [0] = theme.colors.blue, [1] = theme.colors.red, [2] = theme.colors.violet }

local widget = textbox()
widget.bg = bg()
widget.bg:set_fg('#ffffff')
widget.bg:set_widget(widget)

local function set_layout(num)
    util.spawn("/usr/bin/dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:" .. num)
end
local function switch_layout(dir)
    util.spawn("/usr/bin/dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd." .. dir .. "_layout")
end

widget:buttons(util.table.join(
    button({ }, 1, function () switch_layout("next") end),
    button({ }, 4, function () switch_layout("next") end),
    button({ }, 5, function () switch_layout("prev") end)
))

widget.update = function (self, layout)
    self:set_text(layouts[layout] or ' ?? ')
    self.bg:set_bg(colors[layout] or theme.colors.base0)
end

dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function (src, layout)
    widget:update(layout)
end)
set_layout(0)

function kbdd.mt:__call(...)
    return widget.bg
end

return setmetatable(kbdd, kbdd.mt)

