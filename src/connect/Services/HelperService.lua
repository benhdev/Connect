--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local framework: module = {} :: module
local HelperService: module = {} :: module

function HelperService.RoundDecimal (self: module, num: number, decimals: number): number
	local multiplier = 1
	for i = 1, decimals do
		multiplier *= 10
	end

	return math.floor(num * multiplier) / multiplier 
end

function HelperService.FormatNumber (self: module, num: number): string
	local keys = {"K", "M", "B", "T", "Q"}

	if num == 0 then
		return "0 :("
	end

	local exponent = math.min(#keys, math.floor(math.log(num, 1000)))
	local key = keys[exponent] or ""

	return self:RoundDecimal(num / (1000 ^ exponent), 2) .. key
end

framework.HelperService = HelperService
return framework
