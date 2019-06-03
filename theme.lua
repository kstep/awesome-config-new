HOME = os.getenv("HOME")

local gears = require("gears")

theme = dofile(HOME .. "/.config/awesome/themes/awesome-solarized/dark/theme.lua")
theme.wallpaper = HOME .. "/.config/awesome/wallpapers/girl.jpg"
theme.font = 'Noto Mono 8'

theme.get_icon = function (icon_name)
    return "/usr/share/icons/Humanity/status/24/" .. icon_name .. ".png"
end

theme.notification_font = 'Noto Mono 10'
-- theme.notification_border_color = theme.border_normal
theme.notification_border_width = 0
theme.notification_opacity = 0.8
theme.notification_margin = 10
theme.notification_shape = function (cr, w, h)
    return gears.shape.infobubble(cr, w, h, 10, 5, w - 20)
end

return theme
