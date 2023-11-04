--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

function module.GetSignal (self, key, instance)
	if typeof(key) == "RBXScriptSignal" then
		return key
	end

	if typeof(key) == "string" then
		local nest = key:split(".")
		if #nest > 2 then
			error("String signals should only have a depth of 2 items e.g: Players.PlayerAdded")
		end
		--typeof(instance :: {}) == "Instance"
		local shorthands = self:SignalShorthands()
		local prefix = shorthands[nest[1]] or (if typeof(instance :: {}) == "Instance" then instance else nil)

		if #nest == 1 and prefix then
			nest = table.pack(prefix, nest[1])
		end

		local service = typeof(nest[1]) == "Instance" and nest[1] or if nest[1]:lower() == "game" then game else game:GetService(nest[1])
		local signal = nest[2]

		return service[signal]
	end
end

function module.SignalShorthands (self)
	return {
		PlayerAdded = "Players";
		PlayerRemoving = "Players";
		Stepped = "RunService";
		RenderStepped = "RunService";
		Heartbeat = "RunService";
	}
end

return module
