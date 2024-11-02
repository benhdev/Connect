--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local framework: module = {} :: module
local HelperService: module = {} :: module

function framework.Session (self, object: object?)
	local storage: object = {}
	storage.Data = object or {}

	function storage:Get (key): any?
		local key = tostring(key)
		local nest = key:split(".")

		local t = self.Data do
			for _,nest in next, nest do
				local nest = tonumber(nest) or nest
				
				if not t[nest] then
					return nil
				end
	
				t = t[nest]
			end
		end

		return t
	end

	function storage:Key (...)
		local parts = {...}
		return table.concat(parts, ".")
	end

	function storage:Update (key, value): ()
		local key = tostring(key)
		local nest = key:split(".")
		table.insert(nest, (#nest), "")

		local t = self.Data do
			for _,nest in next, nest do
				if nest:len() == 0 then
					break
				end
				
				local nest = tonumber(nest) or nest
				
				if not t[nest] then
					t[nest] = {}
				end

				t = t[nest]
			end
		end

		t[tonumber(nest[#nest]) or nest[#nest]] = value
		
		if self.onUpdateHandler and typeof(self.onUpdateHandler) == "function" then
			self:onUpdateHandler(key, value)
		end
		
		if self.updateHandlers[key] then
			for _,callback in next, self.updateHandlers[key] do
				if typeof(callback) == "function" then
					callback(self, value)
				end
			end
		end
	end

	function storage:Remove (key): ()
		local key = tostring(key)
		local nest = key:split(".")
		
		table.insert(nest, (#nest), "")

		local t = self.Data do
			for _,nest in next, nest do
				if nest:len() == 0 then
					break
				end
				
				local nest = tonumber(nest) or nest
				
				if not t[nest] then
					return
				end

				t = t[nest]
			end
		end

		t[tonumber(nest[#nest]) or nest[#nest]] = nil
		
		if self.updateHandlers[key] then
			self.updateHandlers[key] = nil
		end
	end
	
	storage.updateHandlers = {}
	
	function storage:onUpdate (key, callback)
		if typeof(key) == "function" then
			rawset(self, "onUpdateHandler", key)
			return
		end
		
		if typeof(key) ~= "string" then
			error("Invalid key for Nest:onUpdate")
		end
		
		if not self.updateHandlers[key] then
			self.updateHandlers[key] = {}
		end
		
		table.insert(self.updateHandlers[key], callback)
	end
	
	return setmetatable(storage, {
		__index = function (self, key)
			return self:Get(key)
		end;
		
		__newindex = function (self, key, value)
			self:Update(key, value)
		end;
	})
end

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
