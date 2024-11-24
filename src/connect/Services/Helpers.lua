--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local framework: module = {} :: module
local Helpers: module = {} :: module

Helpers.RandomGenerator = Random.new(os.time())

function Helpers.RoundDecimal (self: module, num: number, decimals: number): number
	local multiplier = 1
	for i = 1, decimals do
		multiplier *= 10
	end

	return math.floor(num * multiplier) / multiplier 
end

function Helpers.FormatNumber (self: module, num: number): string
	local keys = {"K", "M", "B", "T", "Q"}

	if num == 0 then
		return "0 :("
	end

	local exponent = math.min(#keys, math.floor(math.log(num, 1000)))
	local key = keys[exponent] or ""

	return self:RoundDecimal(num / (1000 ^ exponent), 2) .. key
end

function Helpers.GetRemote (self: module, name: string): RemoteEvent | RemoteFunction
	return ReplicatedStorage:WaitForChild(name, 5)
end

function Helpers.FireClient (self: module, key: string, client: Player, data: object?)
	local remote = self:GetRemote(key)
	remote:FireClient(client, data)
end

function Helpers.FireAllClients (self: module, key: string, data: object?)
	local remote = self:GetRemote(key)
	remote:FireAllClients(data)
end

function Helpers.FireServer (self: module, key: string, data: any?)
	local remote = self:GetRemote(key)
	remote:FireServer(data)
end

function Helpers.OnClientEvent (self: module, key: string, callback: (...any?) -> ...any?)
	local remote = self:GetRemote(key)
	remote.OnClientEvent:Connect(callback)
end

function Helpers.InvokeServer (self: module, key: string, data: object?): any
	local remote = self:GetRemote(key)
	return remote:InvokeFunction(data)
end

function Helpers.RandomInteger (self: module, min: number, max: number): number
	return self.RandomGenerator:NextInteger(min, max)
end

function Helpers.RandomNumber (self: module, ...: number?): number
	return self.RandomGenerator:NextNumber(...)
end

framework.Helpers = Helpers
return framework
