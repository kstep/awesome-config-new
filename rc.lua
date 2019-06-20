modkey = "Mod4"
terminal = "xfce4-terminal"

local theme = require("theme")
local beautiful = require("beautiful")
beautiful.init(theme)

local awful = require("awful")
awful.rules = require("awful.rules")
awful.rules.rules = require("rules")

local naughty = require("naughty")
naughty.config.defaults.margin = theme.notification_margin
naughty.config.defaults.icon_size = theme.notification_icon_size
naughty.config.icon_size = theme.notification_icon_size
naughty.config.icon_dirs = theme.notification_icon_dirs

local menubar = require("menubar")
menubar.utils.terminal = terminal

require("awful.autofocus")
require("handlers")

local topbar = require("topbar")
awful.screen.connect_for_each_screen(topbar)

local keys = require("globalkeys")
root.buttons(keys.mouse)
root.keys(keys.keyboard)

require("autostart")
