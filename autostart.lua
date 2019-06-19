local awful = require("awful")

local commands = {
    "setxkbmap -model pc105 -layout us,ru -option grp:caps_toggle,compose:ralt",
    "light-locker",
}

for _, c in ipairs(commands) do
    awful.spawn.once(c)
end
