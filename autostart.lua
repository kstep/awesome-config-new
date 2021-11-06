local awful = require("awful")

local commands = {
    "setxkbmap -model pc105 -layout us,ru -option grp:caps_toggle,compose:ralt",
    "xrdb -merge -I/home/kstep /home/kstep/.Xresources",
    "synclient TapButton1=1",
}

for _, c in ipairs(commands) do
    awful.spawn.once(c)
end
