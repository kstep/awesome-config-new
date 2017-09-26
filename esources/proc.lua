local object = require('gears.object')
local pairs = pairs
local setmetatable = setmetatable
local timer = require("gears.timer")
local io = io
local table = table

module('esources.proc')

function new(args)
    local timeout = args.timeout or 10
    local proc_path = '/proc/' .. args.path
    local fields = args.fields
    local cols = #fields
    local rows = args.rows or 1
    local pattern = '^(%S+)' .. ('%s(%S+)'):rep(cols-1) .. '$'

    local old_value = {}
    local esrc = object()
    --esrc:add_signal('value::updated')

    local update = function (self)
	local value = {}
	local dirty = false
	local line, data
        local i = 0

	for line in io.lines(proc_path) do
            i = i + 1
            if i > rows then break end

            data = line:match(pattern)
	    value
	end

	if dirty then
	    self:emit_signal('value::updated', value)
	    old_value = value
	end
    end
    esrc.update = update
    esrc.timer = timer { timeout = timeout }

    esrc.timer:connect_signal('timeout', function () esrc:update() end)
    if not esrc.timer.started then
        esrc.timer:start()
    end

    return esrc
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })


