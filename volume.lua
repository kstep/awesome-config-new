local awful = require("awful")
local wutil = require("widgets.util")

local parse_mixer_output, raise_volume, lower_volume, toggle_volume
local function notify_volume(mixer_output, toggle)
    local pvol, muted = parse_mixer_output(mixer_output, toggle)
    if not pvol then return end

    local volicon = "medium"
    if muted or pvol == 0 then
        volicon = "muted"
    elseif pvol < 40 then
        volicon = "low"
    elseif pvol > 80 then
        volicon = "high"
    end

    wutil.show_level_notification("Volume ", pvol, "audio-volume-" .. volicon, muted and "muted" or nil)
end

local function parse_alsa_mixer_output(output, toggle)
    local vol, pvol, dbvol, muted = output:match("(%d+) %[(%d+)%%%] %[([%d.+-]+)dB%] %[(%a+)%]")
    return tonumber(pvol), muted == "off"
end

local function parse_oss_mixer_output(output, toggle)
    local dbvol = output:match("(%d+.%d+)")
    dbvol = tonumber(dbvol)
    return dbvol * 100.0 / 25.0, toggle and (dbvol == 0.0)
end

local function parse_pa_mixer_output(output, toggle)
    local vol, muted = output:match("(%d+)\n(%a+)")
    return tonumber(vol), muted == "true"
end

local function parse_pulsemixer_output(output, toggle)
    local voll, volr, muted = output:match("(%d+) (%d+)\n(%d)")
    return math.min(tonumber(voll), tonumber(volr)), muted == "1"
end

if type(awful.spawn("ossvol")) == "number" then -- OSS mixer
    parse_mixer_output = parse_oss_mixer_output
    raise_volume = "ossvol -i 1"
    lower_volume = "ossvol -d 1"
    toggle_volume = "ossvol -t"
elseif type(awful.spawn("pulsemixer")) == "number" then -- PA mixer
    parse_mixer_output = parse_pulsemixer_output
    raise_volume = "pulsemixer --change-volume +5 --get-volume --get-mute"
    lower_volume = "pulsemixer --change-volume -5 --get-volume --get-mute"
    toggle_volume = "pulsemixer --toggle-mute --get-volume --get-mute"
elseif type(awful.spawn("pamixer")) == "number" then -- PA mixer
    parse_mixer_output = parse_pa_mixer_output
    raise_volume = "pamixer --increase 5 --allow-boost && pamixer --get-volume && pamixer --get-mute"
    lower_volume = "pamixer --decrease 5 --allow-boost && pamixer --get-volume && pamixer --get-mute"
    toggle_volume = "pamixer --toggle-mute && pamixer --get-volume && pamixer --get-mute"
else -- ALSA mixer
    parse_mixer_output = parse_alsa_mixer_output
    raise_volume = "amixer -c " .. widgets_config.alsa_card .. " set Master playback 5+"
    lower_volume = "amixer -c " .. widgets_config.alsa_card .. " set Master playback 5-"
    toggle_volume = "amixer -c " .. widgets_config.alsa_card .. " set Master playback toggle"
end

return {
    raise = function ()
        notify_volume(wutil.pread(raise_volume))
    end,
    lower = function ()
        notify_volume(wutil.pread(lower_volume))
    end,
    toggle = function ()
        notify_volume(wutil.pread(toggle_volume, true))
    end,
}
