local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local theme = require("beautiful")
local layouts = require("layouts")

local widgets_config = require("widgets.config")
local widgets = {
    battery = require("widgets.battery"),
    network = require("widgets.network"),
    uptime = require("widgets.uptime"),
}

local mytextclock = wibox.widget.textclock()
local calendar_popup = awful.widget.calendar_popup.month()
calendar_popup.shape = function (cr, w, h)
    return gears.shape.infobubble(cr, w, h, 10, 5, w - 20)
end
calendar_popup:attach(mytextclock)

local mytaglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function (t) t:view_only() end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                    )
local mytasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      c:tags()[1]:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

local uptime_widget, network_widget, battery_widgets
if widgets.uptime then
    uptime_widget = widgets.uptime()
end

if widgets.network and widgets_config.wifi then
    network_widget = widgets.network(widgets_config.wifi, 10)
end

if widgets.battery and widgets_config.batteries then
    battery_widgets = { layout = wibox.layout.fixed.horizontal }
    for i, battery in ipairs(widgets_config.batteries) do
        battery_widgets[i] = widgets.battery(battery, 10)
    end
end

return function (s)
    if theme.wallpaper then
        local g = s.geometry
        local wp = theme.wallpaper:format(g.width, g.height)
        gears.wallpaper.maximized(wp, s, true)
    end

    -- Create a promptbox for each screen
    local mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    local mylayoutbox = awful.widget.layoutbox(s)
    mylayoutbox:buttons(awful.util.table.join(
                        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    local mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, mytaglist_buttons)

    -- Create a tasklist widget
    local mytasklist = awful.widget.tasklist(
        s,
        awful.widget.tasklist.filter.currenttags,
        mytasklist_buttons)

    -- Create keyboard layout widget
    local kbdlayout_widget = awful.widget.keyboardlayout()

    -- Create the wibox
    local mywibox = awful.wibar({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = {
        layout = wibox.layout.fixed.horizontal,
        mytaglist,
        mypromptbox
    }

    -- Widgets that are aligned to the right
    local right_layout = {
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray(),
        uptime_widget,
        network_widget,
        mytextclock,
        battery_widgets,
        kbdlayout_widget,
        mylayoutbox
    }

    -- Now bring it all together (with the tasklist in the middle)
    local layout = {
        layout = wibox.layout.align.horizontal,
        left_layout,
        mytasklist,
        right_layout
    }

    mywibox:setup(layout)

    s.mywibox = mywibox
end

