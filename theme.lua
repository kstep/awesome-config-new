HOME = os.getenv("HOME")

local gears = require("gears")

theme = dofile(HOME .. "/.config/awesome/themes/awesome-solarized/dark/theme.lua")
theme.wallpaper = HOME .. "/.config/awesome/wallpapers/boards.jpg"
theme.font = 'Noto Mono 8'

theme.notification_font = 'Noto Mono 10'
-- theme.notification_border_color = theme.border_normal
theme.notification_border_width = 0
theme.notification_opacity = 0.8
theme.notification_margin = 10
theme.notification_icon_size = 32
theme.notification_shape = function (cr, w, h)
    return gears.shape.infobubble(cr, w, h, 10, 5, w - 20)
end
theme.notification_icon_dirs = {
    "/usr/share/icons/Adwaita/",
    "/usr/share/icons/gnome/",
    "/usr/share/icons/oxygen/",
    "/usr/share/icons/oxygen/base/",
    "/usr/share/icons/hicolor/",
    "/usr/share/icons/HighContrast/",
    "/usr/share/pixmaps/",
}

return theme
