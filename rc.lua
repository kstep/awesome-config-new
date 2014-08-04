-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Themes define colours, icons, and wallpapers
beautiful.init("/home/kstep/.config/awesome/theme.lua")

widgets = {
    battery = require("widgets.battery"),
    network = require("widgets.network"),
    uptime = require("widgets.uptime"),
    kbdd = require("widgets.kbdd"),
}

SCREENS = screen.count()

naughty.config.defaults.screen = SCREENS

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.right,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
function create_tag_keys(i, tag)
    return awful.util.table.join(
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                      awful.tag.viewonly(tag)
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      awful.tag.viewtoggle(tag)
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          awful.client.movetotag(tag)
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          awful.client.toggletag(tag)
                      end
                  end)
    )
end

layout = awful.layout.suit
tags_desc = {
    term = { position = 1, layout = layout.tile.bottom, init = true, screen = 2 },
    skype = { position = 2, layout = layout.tile, screen = 1, mwfact = 0.7 },
    chat = { layout = layout.tile, screen = 1 },
    www  = { position = 3, layout = layout.max, screen = 2, spawn = "/usr/bin/firefox" },
    mail = { position = 4, layout = layout.max, screen = 1, spawn = "/usr/bin/thunderbird" },
    video = { position = 5, screen = 2, layout = layout.max.fullscreen, nopopup = false },
    debug = { position = 6, screen = 2, layout = layout.tile.bottom, nopopup = false },
    edit = { position = 7, layout = layout.tile.bottom, screen = 2, spawn = "/usr/bin/gvim" },
    gimp = { layout = layout.max, screen = 2, spawn = "/usr/bin/gimp" },
    vbox = { layout = layout.max, screen = 2 },
    vnc = { layout = layout.max, screen = 2 },
    libre = { screen = 1 },
    droid = { screen = 2 },
}

tags = {}
all_tags = {}
tag_keys = {}
for s = 1, screen.count() do
    tags[s] = {}
end

for n, a in pairs(tags_desc) do
    local s = math.min(a.screen or 1, #tags)
    a.screen = s

    local t = awful.tag.add(n, a)
    local p = a.position or (#tags[s] + 1)

    if a.position then
        tag_keys = awful.util.table.join(tag_keys, create_tag_keys(a.position, t))
    end

    tags[s][p] = t
    all_tags[n] = t
end
awful.tag.viewonly(all_tags.term)

-- }}}

-- {{{ Menu
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
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

local widgets_config = require("widgets.config")
battery_widget = widgets.battery(widgets_config.battery, 10)
uptime_widget = widgets.uptime()
network_widget = widgets.network(widgets_config.wifi, 10)

for s = 1, SCREENS do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == SCREENS then right_layout:add(wibox.widget.systray()) end

    right_layout:add(battery_widget)
    right_layout:add(uptime_widget)
    right_layout:add(network_widget)

    right_layout:add(mytextclock)

    if s == SCREENS then right_layout:add(widgets.kbdd()) end
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function parse_alsa_mixer_output(output, toggle)
    local vol, pvol, dbvol, muted = output:match("(%d+) %[(%d+)%%%] %[([%d.+-]+)dB%] %[(%a+)%]")
    return tonumber(pvol), muted == "off"
end

function parse_oss_mixer_output(output, toggle)
    local dbvol = output:match("(%d+.%d+)")
    dbvol = tonumber(dbvol)
    return dbvol * 100.0 / 25.0, toggle and (dbvol == 0.0)
end

local parse_mixer_output, raise_volume, lower_volume, toggle_volume
if type(awful.util.spawn("ossvol")) == "number" then -- OSS mixer
    parse_mixer_output = parse_oss_mixer_output
    raise_volume = "ossvol -i 1"
    lower_volume = "ossvol -d 1"
    toggle_volume = "ossvol -t"
else -- ALSA mixer
    parse_mixer_output = parse_alsa_mixer_output
    raise_volume = "amixer set Master playback 5+"
    lower_volume = "amixer set Master playback 5-"
    toggle_volume = "amixer set Master playback toggle"
end

local volume_notification
function notify_volume(mixer_output, toggle)
    local pvol, muted = parse_mixer_output(mixer_output, toggle)
    if not pvol then return end

    local volicon = "medium"
    local voltext = pvol .. "%"
    if muted or pvol == 0 then
        volicon = "muted"
    elseif pvol < 20 then
        volicon = "low"
    elseif pvol > 80 then
        volicon = "high"
    end

    if volume_notification then
        naughty.destroy(volume_notification)
    end

    local barsize = math.floor(pvol / 10)
    local bar = ("▣"):rep(barsize) .. ("□"):rep(10 - barsize)

    volume_notification = naughty.notify {
        title = "Volume " .. (muted and "muted" or (pvol .. "%")),
        text = bar,
        timeout = 5,
        icon = "/usr/share/icons/oxygen/32x32/status/audio-volume-" .. volicon .. ".png",
        screen = screen.count(),
    }
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ }, "Pause", function ()
        awful.util.spawn_with_shell("xrandrconf.sh same-as; sleep 1; slimlock; xrandrconf.sh right-of")
    end),
    awful.key({ }, "Print", function ()
        awful.util.spawn("scrot -s")
    end),
    awful.key({ modkey, }, "Left", function ()
        local tag
        repeat
            awful.tag.viewprev()
            tag = awful.tag.selected()
        until #tag:clients() > 0
    end),
    awful.key({ modkey, }, "Right", function ()
        local tag
        repeat
            awful.tag.viewnext()
            tag = awful.tag.selected()
        until #tag:clients() > 0
    end),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Escape",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
    awful.key({ }, "XF86AudioRaiseVolume", function () notify_volume(awful.util.pread(raise_volume)) end),
    awful.key({ }, "XF86AudioLowerVolume", function () notify_volume(awful.util.pread(lower_volume)) end),
    awful.key({ }, "XF86AudioMute", function () notify_volume(awful.util.pread(toggle_volume, true)) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
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

globalkeys = awful.util.table.join(globalkeys, tag_keys)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },

    { rule = { instance = "chromium_app_list" }, properties = { floating = true } },
    { rule = { instance = "chrome_app_list" }, properties = { floating = true } },

    { rule = { role = "popup" }, properties = { y = 0, x = 0 } },

    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "gimp" }, properties = { floating = true } },
    { rule = { class = "Skype" }, properties = { tag = all_tags.skype } },
    { rule = { class = "Gvim" }, properties = { tag = all_tags.edit } },
    { rule = { class = "XTerm" }, properties = { tag = all_tags.term, opacity = 0.9 } },
    { rule = { class = "MPlayer" }, properties = { tag = all_tags.video } },
    { rule = { class = "VCLSalFrame" }, properties = { tag = all_tags.libre } },
    { rule = { class = "Google-chrome-unstable" }, properties = { tag = all_tags.www } },
    { rule = { class = "Google-chrome" }, properties = { tag = all_tags.www } },
    { rule = { class = "Chromium" }, properties = { tag = all_tags.www } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
