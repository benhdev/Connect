--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? } 
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local events: module = {} :: module
events.RandomGenerator = Random.new(os.time())

local ReplicatedStorage = game:GetService('ReplicatedStorage')

function events.GetRemote (self: module, name: string): RemoteEvent | RemoteFunction
	return ReplicatedStorage:WaitForChild(name, 5)
end

function events.FireClient (self: module, key: string, client: Player, data: object?)
	local remote = self:GetRemote(key)
	remote:FireClient(client, data)
end

function events.FireAllClients (self: module, key: string, data: object?)
	local remote = self:GetRemote(key)
	remote:FireAllClients(data)
end

function events.FireServer (self: module, key: string, data: any?)
	local remote = self:GetRemote(key)
	remote:FireServer(data)
end

function events.OnClientEvent (self: module, key: string, callback: (...any?) -> ...any?)
	local remote = self:GetRemote(key)
	remote.OnClientEvent:Connect(callback)
end

function events.InvokeServer (self: module, key: string, data: object?): any
	local remote = self:GetRemote(key)
	return remote:InvokeFunction(data)
end

function events.RandomInteger (self: module, min: number, max: number): number
	return self.RandomGenerator:NextInteger(min, max)
end

function events.RandomNumber (self: module, ...: number?): number
	return self.RandomGenerator:NextNumber(...)
end

function events.RoundDecimal (self: module, num: number, decimals: number): number
	local multiplier = 1
	for i = 1, decimals do
		multiplier *= 10
	end
	
	return math.floor(num * multiplier) / multiplier 
end
	
function events.FormatNumber (self: module, num: number): string
	local keys = {"K", "M", "B", "T", "Q"}

	if num == 0 then
		return "0 :("
	end

	local exponent = math.min(#keys, math.floor(math.log(num, 1000)))
	local key = keys[exponent] or ""

	return self:RoundDecimal(num / (1000 ^ exponent), 2) .. key
end

local globalEvents = {}

return {
    -- EventHelpers = events,

    event = function (self, key)
        key = key or "global"

        local event = globalEvents[key] or {
            name = key,

            listen = function (self, key, callback)
                self.listeners[key] = callback
            end,

            find = function (self, key)
                if (self.listeners[key]) then
                    return self.listeners[key]
                end

                return nil
            end,

            dispatch = function (self, key, ...)
                if self.listeners[key] then
                    local response = table.pack(self.listeners[key](...))

                    if self:find(`{key}.finished`) then
                        self.listeners[`{key}.finished`](unpack(response))
                    end

                    return unpack(response)
                else
                    warn(`{key} Event not found`)
                end
            end,

            listeners = {},
        }

        event.fire = event.dispatch

        globalEvents[key] = event

        return event
    end
}
