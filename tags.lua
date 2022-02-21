local awful = require("awful")
local layout = awful.layout.suit

local tags_desc = {
    term = { position = 1, layout = layout.tile.bottom, },
    skype = { position = 2, layout = layout.tile, mwfact = 0.7 },
    www  = { position = 3, layout = layout.max, },
    mail = { position = 4, layout = layout.max, },
    video = { position = 5, layout = layout.max.fullscreen },
    debug = { position = 6, layout = layout.tile.bottom },
    edit = { position = 7, layout = layout.tile.bottom, },
    util = { position = 8, layout = layout.tile.bottom, },

    music = { layout = layout.max, },

    chat = { layout = layout.tile, },
    java = { layout = layout.max, },
    gimp = { layout = layout.max, },
    vbox = { layout = layout.max, },
    vnc = { layout = layout.max, },
    libre = { },
    droid = { },
    karma = { layout = layout.fair },
}

local tags = {}
local all_tags = {}

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

    tags[s][p] = t
    all_tags[n] = t
end

return all_tags
