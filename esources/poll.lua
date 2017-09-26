local timer = require("gears.timer")
local setmetatable = setmetatable

module('esources.poll')

local pollers = {}

function new(timeout)
    if not pollers[timeout] then
	pollers[timeout] = timer { timeout = timeout }
    end
    return pollers[timeout]
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })

