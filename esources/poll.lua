local timer = require("gears.timer")
local setmetatable = setmetatable

local poll = { mt = {} }

local pollers = {}

function poll.new(timeout)
    if not pollers[timeout] then
	pollers[timeout] = timer { timeout = timeout }
    end
    return pollers[timeout]
end

function poll.mt:__call(...)
    return poll.new(...)
end

return setmetatable(poll, poll.mt)

