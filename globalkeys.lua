local awful = require("awful")
local menubar = require("menubar")
local wutil = require("widgets.util")
local naughty = require("naughty")
local volume = require("volume")


local reset_backlight = "echo 0 | sudo tee '/sys/class/backlight/intel_backlight/bl_power'"
local lower_brightness = reset_backlight .. "; xbacklight -dec 1"
local raise_brightness = reset_backlight .. "; xbacklight -inc 1"

local function parse_xbacklight_output(output)
    return tonumber(output:match("(%d+)"))
end

local function notify_brightness(output)
    local brightness = parse_xbacklight_output(output)
    wutil.show_level_notification("Brightness ", brightness, "devices/video-display")
end


local function invert_current_client()
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



local globalkeys = awful.util.table.join(
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

    awful.key({ modkey }, "z", function () awful.spawn("dm-tool lock") end),

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

    awful.key({ modkey }, "Up", volume.raise),
    awful.key({ }, "XF86AudioRaiseVolume", volume.raise),

    awful.key({ modkey }, "Down", volume.lower),
    awful.key({ }, "XF86AudioLowerVolume", volume.lower),

    awful.key({ modkey }, "End", volume.toggle),
    awful.key({ }, "XF86AudioMute", volume.toggle),

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
)

local tag_keys = {}

local function create_tag_keys(i, tag)
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

local tags = require("tags")
for n, a in pairs(tags) do
    if a.position then
        tag_keys = awful.util.table.join(tag_keys, create_tag_keys(a.position, a))
    end
end

globalkeys = awful.util.table.join(globalkeys, tag_keys)

local globalbuttons = awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
)

return {
    keyboard = globalkeys,
    mouse = globalbuttons,
}
