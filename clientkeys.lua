local awful = require("awful")

local function screen_right_edge()
    local s = mouse.screen
    return s.workarea.x + s.workarea.width
end
local function screen_bottom_edge()
    local s = mouse.screen
    return s.workarea.y + s.workarea.height
end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.sticky = not c.sticky          end),
    awful.key({ modkey, "Control" }, "t",      function (c)
        if c.sticky then
            c.sticky = false
            c.floating = false
        else
            local geo = c:geometry()
            c.sticky = true
            c.floating = true
            c.maximized_horizontal = false
            c.maximized_vertical = false
            c:geometry({
                x = screen_right_edge() - geo.width,
                y = screen_bottom_edge() - geo.height
            })
        end
    end),
    awful.key({ modkey,           }, "equal", function (c) c.opacity = c.opacity + 0.05 end),
    awful.key({ modkey,           }, "minus", function (c) c.opacity = c.opacity - 0.05 end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

return {
    mouse = clientbuttons,
    keyboard = clientkeys,
}
