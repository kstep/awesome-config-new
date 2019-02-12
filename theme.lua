HOME = os.getenv("HOME")

--theme = dofile(HOME .. "/.config/awesome/themes/awesome-solarized/light/theme.lua")
theme = dofile(HOME .. "/.config/awesome/themes/awesome-solarized/dark/theme.lua")
--theme.wallpaper_cmd = { "awsetbg " .. HOME .. "/.config/awesome/wallpaper.png" }
theme.wallpaper = HOME .. "/.config/awesome/wallpapers/girl.jpg"
--theme.wallpaper = HOME .. "/.config/awesome/wallpapers/WrongEye_%dx%d.png"
--theme.font = 'Terminus 8'
theme.font = 'Noto Mono 8'
return theme
