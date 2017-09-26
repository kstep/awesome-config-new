local awful = require("awful")
local layout = awful.layout.suit

local tags_desc = {
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

local tags = {}
local all_tags = {}
local tag_keys = {}
local screens = screen.count()

for s = 1, screens do
    tags[s] = {}
end

for n, a in pairs(tags_desc) do
    local s = math.min(screens, a.screen or 1)
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

return all_tags
