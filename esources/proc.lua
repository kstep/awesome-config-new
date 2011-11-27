local object = require('gears.object')
local pairs = pairs
local setmetatable = setmetatable
local timer = timer
local io = io

module('esources.proc')

function new(args)
    local timeout = args.timeout or 10
    local proc_path = '/proc/' .. args.path
    local fields = args.fields

    local old_value = {}
    local esrc = object()
    esrc:add_signal('value::updated')

    local update = function (self)
	local value = {}
	local dirty = false
	local line, k, v

	for line in io.lines(proc_path) do
	    -- TODO: split line by k and v
	    if v ~= old_value[k] then dirty = true end
	    value[k] = v
	end

	if dirty then
	    self:emit_signal('value::updated', value)
	    old_value = value
	end
    end
    esrc.update = update
    esrc.timer = timer { timeout = timeout }

    esrc.timer:connect_signal('timeout', function () esrc:update() end)
    esrc.timer:start()

    return esrc
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })


