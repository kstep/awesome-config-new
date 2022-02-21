local theme = require("beautiful")
local awful = require("awful")
local keys = require("clientkeys")

local tags = require("tags")

local function screen_right_edge()
    local s = mouse.screen
    return s.workarea.x + s.workarea.width
end
local function screen_bottom_edge()
    local s = mouse.screen
    return s.workarea.y + s.workarea.height
end

return {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = theme.border_width,
                     border_color = theme.border_normal,
                     focus = awful.client.focus.filter,
                     keys = keys.keyboard,
                     buttons = keys.mouse } },

    { rule = { class = "SshAskpass" }, properties = { ontop = true, floating = true, modal = true, sticky = true, tag = tags.term } },

    { rule_any = { instance = {"chromium_app_list", "chrome_app_list"} }, properties = { floating = true } },

    { rule_any = { class = {"SWT", "Eclipse"} }, properties = { tag = tags.java } },

    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "gimp" }, properties = { floating = true } },

    { rule_any = { class = {"st-256color", "XTerm", "Xfce4-terminal"} }, properties = { tag = tags.term, opacity = 0.95, focus = true, switchtotag = true } },

    { rule = { class = "MPlayer" }, properties = { tag = tags.video } },

    { rule = { class = "Spotify" }, properties = { tag = tags.music } },

    { rule = { class = "VCLSalFrame" }, properties = { tag = tags.libre } },

    { rule_any = { class = { "Geary", "Nylon N1" } }, properties = { tag = tags.mail } },

    { rule_any = { class = {
        "chromium", "google-chrome", "google-chrome-beta", "google-chrome-unstable",
        "Firefox", "Dwb", "Vimb", "Opera"}, instance = {"Browser"}, role = {"browser"} },
      properties = { tag = tags.www, focus = true, switchtotag = true } },

    { rule = { name = "Picture in picture" }, properties = { floating = true, geometry = {
        width = 380, height = 215, x = screen_right_edge() - 400, y = screen_bottom_edge() - 240
    } } },

    { rule_any = { class = {"Skype"}, instance = {"web.skype.com"} }, properties = { tag = tags.skype, focus = true, switchtotag = true } },

    { rule_any = { class = {"Emacs", "Gvim", "Atom Shell", "jetbrains-idea-ce", "jetbrains-pycharm-ce", "Code"} }, properties = { tag = tags.edit } },

    { rule = { role = "popup" }, properties = { screen = function () return mouse.screen end, geometry = function () return {
        x = screen_right_edge() - 350,
        y = mouse.screen.workarea.y
    } end } },

    { rule = { class = "discord" }, properties = { tag = tags.chat } },
    { rule_any = { class = {"ViberPC", "TelegramDesktop", "Slack", "zoom"} }, properties = { tag = tags.chat, focus = false } },
    { rule = { class = "ViberPC", name = "Form" }, properties = { floating = true, geometry = {
        x = screen_right_edge() - 350,
        y = mouse.screen.workarea.y
    }, screen = 1 } },

    { rule = { name = "^Karma" }, properties = { tag = tags.karma } },

}
