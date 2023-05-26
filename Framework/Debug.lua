--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

function module.DebugEnabled (self, v)
	if typeof(v) == "boolean" or typeof(v) == "string" then
		self.DebugMode = v
	end

	return self.DebugMode
end

function module.CallstackLevel (self)
	local depth = 0

	while true do
		if not debug.info(3 + depth, "n") then
			break
		end

		depth += 1
	end

	return depth
end

return module