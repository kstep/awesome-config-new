local object = require('gears.object')
local poll = require('esources.poll')
local pairs = pairs
local setmetatable = setmetatable
local io = io

local _M = {}

local function readfile(filename, format)
    local file = io.open(filename)
    if not file then return nil end

    local result = file:read(format or "*a")
    file:close()
    return result
end

local function new(args)
    local timeout = args.timeout or 10
    local sys_path = '/sys/' .. args.path .. '/'
    local fields = args.fields

    local old_value = {}
    local esrc = object()
    --esrc:add_signal('value::updated')

    local update = function (self)
	local value = {}
	local dirty = false

	for k, v in pairs(fields) do
	    local r = readfile(sys_path .. k, v)
	    if r ~= old_value[k] then dirty = true end
	    value[k] = r
	end

	if dirty then
	    self:emit_signal('value::updated', value, old_value)
	    old_value = value
	end
    end
    esrc.update = update
    esrc.timer = poll(timeout)

    esrc.timer:connect_signal('timeout', function () esrc:update() end)
    if not esrc.timer.started then
        esrc.timer:start()
    end

    return esrc
end

return setmetatable(_M, { __call = function (_, ...) return new(...) end })

