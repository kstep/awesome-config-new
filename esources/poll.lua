local timer = require("gears.timer")
local setmetatable = setmetatable

local _M = {}

local pollers = {}

local function new(timeout)
    if not pollers[timeout] then
	pollers[timeout] = timer { timeout = timeout }
    end
    return pollers[timeout]
end

return setmetatable(_M, { __call = function (_, ...) return new(...) end })

