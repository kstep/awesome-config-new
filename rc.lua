-- Standard awesome library
require("awful")
require("awful.autofocus")
-- Widget and layout library
require("wibox")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

require("shifty")

require("widgets.battery")
require("widgets.network")
require("widgets.uptime")
require("widgets.kbdd")

SCREENS = screen.count()

naughty.config.presets.normal.screen = SCREENS
naughty.config.presets.low.screen = SCREENS
naughty.config.presets.critical.screen = SCREENS

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
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
layout = awful.layout.suit
shifty.config.tags = {
    term = { position = 1, layout = layout.tile.bottom, init = true, screen = 2 },
    im = { position = 2, layout = layout.tile.right, mwfact = 0.75, screen = 1, spawn = "/usr/bin/pidgin" },
    skype = { layout = layout.tile.right, screen = 1 },
    www  = { position = 3, layout = layout.max, screen = 2, spawn = "/usr/bin/firefox" },
    mail = { position = 4, layout = layout.max, screen = 1, spawn = "/usr/bin/thunderbird" },
    video = { position = 5, screen = 1, layout = layout.max.fullscreen, nopopup = false },
    debug = { position = 6, screen = 1, layout = layout.tile.bottom, nopopup = false },
    edit = { position = 9, layout = layout.tile.bottom, screen = 2, spawn = "/usr/bin/gvim" },
    gimp = { layout = layout.magnifier, screen = 2, spawn = "/usr/bin/gimp" },
}
shifty.config.apps = {
    { match = {"Skype"}, tag = "skype" },
    { match = {"Thunderbird"}, tag = "mail" },
    { match = {"Gvim", "Vim", "Sublime_text"}, tag = "edit" },
    { match = {"Firefox", "Google.*", "Opera", "Chromium"}, tag = "www" },
    { match = {"libreoffice-.*"}, tag = "libre" },
    { match = {"Vimprobable2"}, tag = "www" },
    { match = {"Toplevel", "Developer Tools.*", "Live HTTP headers"}, tag = "debug" },
    { match = {"xterm"}, tag = "term" },
    { match = {"Pidgin"}, tag = "im" },
    { match = {"MPlayer"}, tag = "video" },
    { match = {"Gimp"}, tag = "gimp" },
    { match = {"Blender"}, tag = "blndr" },
    { match = {"Ruler", "kruler"}, float = true, sticky = true, nopopup = false, ontop = true },
}
shifty.config.defaults = {
    layout = layout.max,
    mwfact = 0.62,
    nopopup = true,
}
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()
mytextclock_t = awful.tooltip {
    objects = { mytextclock },
    timer_function = function () return awful.util.pread('cal -ym') end,
    timeout = 60
}

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function (c)
                                            c:kill()
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

battery_widget = widgets.battery('BAT0', 10)
network_widget_ppp0 = widgets.network('ppp0', 10)
network_widget_wlan0 = widgets.network('wlan0', 10)
uptime_widget = widgets.uptime()

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
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

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
    right_layout:add(network_widget_ppp0)
    right_layout:add(network_widget_wlan0)

    right_layout:add(uptime_widget)
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

-- {{{ Key bindings
function stardict_translate()
    local function translate_word(word)
        local translation = awful.util.pread('sdcv -u "English-Russian full dictionary" -n "'..word..'"')
        naughty.notify { title = word, text = translation, timeout = 0, width = 500, screen = SCREENS }
    end

    --local word = util.pread("xsel")
    local word = selection()
    if word == "" then
        awful.prompt.run({ prompt = "Dict: " },
        mypromptbox[mouse.screen].widget,
        translate_word, nil,
        awful.util.getdir("cache") .. "/history_stardict")
    else
        translate_word(word)
    end
end

function spawner(cmd) return function () awful.util.spawn(cmd) end end
globalkeys = awful.util.table.join(
    awful.key({ modkey }, "t", stardict_translate),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore),

    awful.key({ }, "XF86AudioPlay", spawner("cmus-remote -u")),
    awful.key({ }, "XF86AudioPrev", spawner("cmus-remote -r")),
    awful.key({ }, "XF86AudioNext", spawner("cmus-remote -n")),
    awful.key({ }, "XF86AudioStop", spawner("cmus-remote -s")),

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
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal .. ' -e tmux') end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "grave",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
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

shifty.config.clientkeys = clientkeys
shifty.config.modkey = modkey

shifty.taglist = mytaglist
shifty.init()

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, '#'..i+9, function () local t = shifty.getpos(i); if t then awful.screen.focus(t.screen); awful.tag.viewonly(t); end end),
        awful.key({ modkey, "Control" }, '#'..i+9, function () local t = shifty.getpos(i); if t then t.selected = not t.selected end end),
        awful.key({ modkey, "Shift" }, '#'..i+9, function () local t = shifty.getpos(i); if t and client.focus then awful.client.movetotag(t) end end),
        awful.key({ modkey, "Control", "Shift" }, '#'..i+9, function () local t = shifty.getpos(i); if t and client.focus then awful.client.toggletag(t) end end)
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
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
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
