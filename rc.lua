-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local wutil = require("widgets.util")
awful.rules = require("awful.rules")
-- Widget and layout library
local wibox = require("wibox")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
--local mpd = require("mpd")
-- Theme handling library
local beautiful = require("beautiful")

require("awful.autofocus")

HOME = os.getenv("HOME")

-- Themes define colours, icons, and wallpapers
beautiful.init(HOME .. "/.config/awesome/theme.lua")

widgets = {
    battery = require("widgets.battery"),
    network = require("widgets.network"),
    uptime = require("widgets.uptime"),
    kbdd = require("widgets.kbdd"),
}

SCREENS = screen.count()
function scr(n)
    return math.min(n, SCREENS)
end

naughty.config.defaults.screen = scr(2)
--naughty.config.defaults.font = "DejaVu Sans Mono"
naughty.config.defaults.font = "Noto Mono 10"
naughty.config.defaults.icon_size = 32
naughty.config.icon_dirs = {
    "/usr/share/icons/Adwaita/",
    "/usr/share/icons/gnome/",
    "/usr/share/icons/oxygen/",
    "/usr/share/icons/hicolor/",
    "/usr/share/pixmaps/",
}

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

function log(msg)
    naughty.notify({ preset = naughty.config.presets.critical,
        title = "Debug",
        text = msg })
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
        local g = screen[s].geometry
        local wp = beautiful.wallpaper:format(g.width, g.height)
        gears.wallpaper.maximized(wp, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
function create_tag_keys(i, tag)
    return awful.util.table.join(
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                      tag:view_only()
                      awful.screen.focus(tag.screen)
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
    term = { position = 1, layout = layout.tile.bottom, screen = scr(2) },
    skype = { position = 2, layout = layout.tile, screen = 1, mwfact = 0.7 },
    www  = { position = 3, layout = layout.max, screen = scr(3) },
    mail = { position = 4, layout = layout.max, screen = scr(3) },
    video = { position = 5, screen = scr(2), layout = layout.max.fullscreen },
    debug = { position = 6, screen = scr(3), layout = layout.tile.bottom },
    edit = { position = 7, layout = layout.tile.bottom, screen = scr(2) },
    util = { position = 8, layout = layout.tile.bottom, screen = scr(3) },

    chat = { layout = layout.tile, screen = 1 },
    java = { layout = layout.max, screen = scr(2) },
    gimp = { layout = layout.max, screen = scr(2) },
    vbox = { layout = layout.max, screen = scr(3) },
    vnc = { layout = layout.max, screen = scr(3) },
    libre = { screen = 1 },
    droid = { screen = scr(3) },
    karma = { screen = scr(2), layout = layout.fair },
}

tags = {}
all_tags = {}
tag_keys = {}
for s = 1, screen.count() do
    tags[s] = {}
end

for n, a in pairs(tags_desc) do
    local s = scr(a.screen or 1)
    a.screen = s

    local p = a.position or (#tags[s] + 1)
    a.index = p

    local t = awful.tag.add(n, a)

    if a.position then
        tag_keys = awful.util.table.join(tag_keys, create_tag_keys(a.position, t))
    end

    tags[s][p] = t
    all_tags[n] = t
end

-- }}}

-- {{{ Menu
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
mytaglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function (t) t:view_only() end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                    )
mytasklist_buttons = awful.util.table.join(
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

local widgets_config = require("widgets.config")
battery_widgets = { layout = wibox.layout.fixed.horizontal }
for i, battery in ipairs(widgets_config.batteries) do
    battery_widgets[i] = widgets.battery(battery, 10)
end
uptime_widget = widgets.uptime()
network_widget = widgets.network(widgets_config.wifi, 10)

--mpc = mpd.new(widgets_config.mpd)
kbdd_screen = scr(2)

awful.screen.connect_for_each_screen(function(s)
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
    local mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist_buttons)

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
        --widgets.kbdd(),
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
end)
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

function parse_pa_mixer_output(output, toggle)
    local vol, muted = output:match("(%d+)\n(%a+)")
    return tonumber(vol), muted == "true"
end

function parse_pulsemixer_output(output, toggle)
    local voll, volr, muted = output:match("(%d+) (%d+)\n(%d)")
    return math.min(tonumber(voll), tonumber(volr)), muted == "1"
end

function parse_xbacklight_output(output)
    return tonumber(output:match("(%d+)"))
end

local parse_mixer_output, raise_volume, lower_volume, toggle_volume
if type(awful.spawn("ossvol")) == "number" then -- OSS mixer
    parse_mixer_output = parse_oss_mixer_output
    raise_volume = "ossvol -i 1"
    lower_volume = "ossvol -d 1"
    toggle_volume = "ossvol -t"
elseif type(awful.spawn("pulsemixer")) == "number" then -- PA mixer
    parse_mixer_output = parse_pulsemixer_output
    raise_volume = "pulsemixer --change-volume +5 --get-volume --get-mute"
    lower_volume = "pulsemixer --change-volume -5 --get-volume --get-mute"
    toggle_volume = "pulsemixer --toggle-mute --get-volume --get-mute"
elseif type(awful.spawn("pamixer")) == "number" then -- PA mixer
    parse_mixer_output = parse_pa_mixer_output
    raise_volume = "pamixer --increase 5 --allow-boost && pamixer --get-volume && pamixer --get-mute"
    lower_volume = "pamixer --decrease 5 --allow-boost && pamixer --get-volume && pamixer --get-mute"
    toggle_volume = "pamixer --toggle-mute && pamixer --get-volume && pamixer --get-mute"
else -- ALSA mixer
    parse_mixer_output = parse_alsa_mixer_output
    raise_volume = "amixer -c " .. widgets_config.alsa_card .. " set Master playback 5+"
    lower_volume = "amixer -c " .. widgets_config.alsa_card .. " set Master playback 5-"
    toggle_volume = "amixer -c " .. widgets_config.alsa_card .. " set Master playback toggle"
end

reset_backlight = "echo 0 | sudo tee '/sys/class/backlight/intel_backlight/bl_power'"
lower_brightness = reset_backlight .. "; xbacklight -dec 1"
raise_brightness = reset_backlight .. "; xbacklight -inc 1"

local level_notification
function show_level_notification(title, percent, icon, muted)
    local barsize = math.floor(percent / 10)
    local bar = ("▣"):rep(barsize) .. ("□"):rep(10 - barsize)

    if level_notification then
        naughty.destroy(level_notification)
    end

    level_notification = naughty.notify {
        title = title .. (muted and "muted" or (percent .. "%")),
        text = bar,
        timeout = 5,
        icon = icon,
        screen = mouse.screen --screen.count(),
    }
end

function notify_volume(mixer_output, toggle)
    local pvol, muted = parse_mixer_output(mixer_output, toggle)
    if not pvol then return end

    local volicon = "medium"
    if muted or pvol == 0 then
        volicon = "muted"
    elseif pvol < 40 then
        volicon = "low"
    elseif pvol > 80 then
        volicon = "high"
    end

    show_level_notification("Volume ", pvol, "status/audio-volume-" .. volicon, muted)
end

function notify_brightness(output)
    local brightness = parse_xbacklight_output(output)
    show_level_notification("Brightness ", brightness, "devices/video-display")
end

function invert_current_client()
    local command = "/usr/bin/dbus-send --print-reply --dest=com.github.chjj.compton._0 /com/github/chjj com.github.chjj.compton."

    awful.spawn(command .. "opts_set string:track_focus boolean:true")

    local output = wutil.pread(command .. "find_win string:focused")

    if output then
        local winid = output:match("uint32 (%d+)")

        if winid then
            local output = wutil.pread(command .. "win_get uint32:" .. winid .. " string:invert_color")
            if output then
                local invert = output:match("boolean (%w+)") == "true"
                awful.spawn(command .. "win_set uint32:" .. winid .. " string:invert_color_force uint16:" .. (invert and 0 or 1))
            end
        end
    end
end

function toggle_touchpad()
    awful.spawn_with_shell([[synclient | awk -F' *= *' '/TouchpadOff/{if ($2 == "0") { print 1 } else { print 0 }}' | xargs -I {} synclient TouchpadOff={}]])
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ }, "Pause", function ()
        awful.spawn_with_shell("systemctl --user start xorg-locker.service")
    end),
    awful.key({ }, "Print", function ()
        awful.spawn("scrot -s")
    end),
    awful.key({ modkey, }, "Left", function ()
        local tag
        repeat
            awful.tag.viewprev()
            tag = mouse.screen.selected_tag
        until #tag:clients() > 0
    end),
    awful.key({ modkey, }, "Right", function ()
        local tag
        repeat
            awful.tag.viewnext()
            tag = mouse.screen.selected_tag
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
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn("systemctl --user start xterm-tmux@default.service") end),
    awful.key({ modkey,           }, "i", invert_current_client),
    awful.key({ modkey, "Control" }, "i", function () awful.spawn("xrandr-invert-colors -s " .. math.floor(mouse.screen - 1)) end),
    awful.key({ modkey, "Shift"   }, "i", function () awful.spawn("xrandr-invert-colors") end),
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
    awful.key({ }, "XF86AudioRaiseVolume", function () notify_volume(wutil.pread(raise_volume)) end),
    awful.key({ }, "XF86AudioLowerVolume", function () notify_volume(wutil.pread(lower_volume)) end),
    awful.key({ }, "XF86AudioMute", function () notify_volume(wutil.pread(toggle_volume, true)) end),
    awful.key({ }, "XF86TouchpadToggle", toggle_touchpad),
    awful.key({ }, "XF86Tools", toggle_touchpad),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.spawn_with_shell(raise_brightness); notify_brightness(wutil.pread("xbacklight -get")) end),
    awful.key({ }, "XF86MonBrightnessDown", function () awful.spawn_with_shell(lower_brightness); notify_brightness(wutil.pread("xbacklight -get")) end),
    awful.key({ "Shift" }, "XF86MonBrightnessUp", function () awful.spawn_with_shell(raise_brightness .. "0"); notify_brightness(wutil.pread("xbacklight -get")) end),
    awful.key({ "Shift" }, "XF86MonBrightnessDown", function () awful.spawn_with_shell(lower_brightness .. "0"); notify_brightness(wutil.pread("xbacklight -get")) end),

    awful.key({ }, "XF86AudioPlay", function () mpc:toggle_play() end),
    awful.key({ }, "XF86AudioStop", function () mpc:stop() end),
    awful.key({ }, "XF86AudioNext", function () mpc:next() end),
    awful.key({ }, "XF86AudioPrev", function () mpc:previous() end)
    --awful.key({ }, "XF86AudioPlay", function () mpc:toggle_play(); notify_mpd_song() end),
    --awful.key({ }, "XF86AudioStop", function () mpc:stop() notify_mpd_song() end),
    --awful.key({ }, "XF86AudioNext", function () mpc:next(); notify_mpd_song() end),
    --awful.key({ }, "XF86AudioPrev", function () mpc:previous(); notify_mpd_song() end)
)

function notify_mpd_song()
    local song = mpc:send("currentsong")
    local status = mpc:send("status")
    local icons = {
        stop = "stop",
        play = "start",
        pause = "pause"
    }
    naughty.notify({
        screen = mouse.screen,
        icon = "actions/media-playback-" .. icons[status.state],
        title = song.title or song.file,
        text = (song.artist or song.composer or "Unknown Artist") .. " / " .. (song.album or song.artistalbum or "Unknown Album")
    })
end

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
                x = screen_right_edge(mouse.screen) - geo.width,
                y = screen_bottom_edge(mouse.screen) - geo.height
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

globalkeys = awful.util.table.join(globalkeys, tag_keys)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

function screen_right_edge(num)
    local s = screen[num]
    return s.workarea.x + s.workarea.width
end
function screen_bottom_edge(num)
    local s = screen[num]
    return s.workarea.y + s.workarea.height
end

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },

    { rule = { class = "SshAskpass" }, properties = { ontop = true, floating = true, modal = true, sticky = true, tag = all_tags.term } },

    { rule_any = { instance = {"chromium_app_list", "chrome_app_list"} }, properties = { floating = true } },

    { rule_any = { class = {"SWT", "Eclipse"} }, properties = { tag = all_tags.java } },

    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "gimp" }, properties = { floating = true } },

    { rule_any = { class = {"st-256color", "XTerm"} }, properties = { tag = all_tags.term, opacity = 0.95, focus = true, switchtotag = true } },

    { rule = { class = "MPlayer" }, properties = { tag = all_tags.video } },

    { rule = { class = "VCLSalFrame" }, properties = { tag = all_tags.libre } },

    { rule_any = { class = { "Geary", "Nylon N1" } }, properties = { tag = all_tags.mail } },

    { rule_any = { class = {
        "chromium", "google-chrome", "google-chrome-beta", "google-chrome-unstable",
        "Firefox", "Dwb", "Vimb", "Opera"}, instance = {"Browser"}, role = {"browser"} },
      properties = { tag = all_tags.www, focus = true, switchtotag = true } },

    { rule_any = { class = {"Skype"}, instance = {"web.skype.com"} }, properties = { tag = all_tags.skype, focus = true, switchtotag = true } },

    { rule_any = { class = {"Emacs", "Gvim", "Atom Shell", "jetbrains-idea-ce", "jetbrains-pycharm-ce", "Code"} }, properties = { tag = all_tags.edit } },

    { rule = { role = "popup" }, properties = { screen = function () return mouse.screen end, geometry = function () return {
        x = screen_right_edge(mouse.screen) - 350,
        y = screen[mouse.screen].workarea.y
    } end } },

    { rule_any = { class = {"ViberPC", "TelegramDesktop", "Slack"} }, properties = { tag = all_tags.chat, focus = false } },
    { rule = { class = "ViberPC", name = "Form" }, properties = { floating = true, geometry = {
        x = screen_right_edge(scr(2)) - 350,
        y = screen[scr(2)].workarea.y
    }, screen = scr(2) } },

    { rule = { name = "^Karma" }, properties = { tag = all_tags.karma } },

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

--awful.spawn("/usr/bin/systemctl --user import-environment DISPLAY")
--awful.spawn("/usr/bin/systemctl --user start wm.target")
