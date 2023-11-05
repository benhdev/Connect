--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local framework: module = {} :: module
local DataService: module = {} :: module

local DataStoreService = game:GetService("DataStoreService")

function DataService.DataStoreRequestTypes (self)
	return {
		get = Enum.DataStoreRequestType.GetAsync;
		set = Enum.DataStoreRequestType.SetIncrementAsync;
		update = Enum.DataStoreRequestType.UpdateAsync;
	}
end

function DataService.DataStore (self)
	return DataStoreService:GetGlobalDataStore()
end

function DataService.DataStoreRequestType (self, key)
	local DataStoreRequestTypes = self:DataStoreRequestTypes()
	return DataStoreRequestTypes[key]
end

function DataService.DataStoreRequestBudget (self, key)
	local DataStoreRequestType = self:DataStoreRequestType(key)
	return DataStoreService:GetRequestBudgetForRequestType(DataStoreRequestType)
end

function DataService.DataStoreThrottle (self, proxy, func, t)
	task.delay(t or 0, function ()
		local success, result = pcall(func, self:DataStore())
		
		if not success then
			if proxy.onErrorHandler then
				proxy:onErrorHandler(result)
			else
				warn(result)
			end
			
			if proxy.shouldRetry then
				proxy.retries += 1
				return self:DataStoreThrottle(proxy, func, 5)
			end
			
			return
		end
		
		return proxy:callback(result), proxy:setFinished()
	end)
end

function DataService.GetAsync (self, key, proxy)
	self:DataStoreThrottle(proxy, function (DataStore: DataStore)
		return DataStore:GetAsync(key)
	end)
end

function DataService.SetAsync (self, key, value, proxy)
	self:DataStoreThrottle(proxy, function (DataStore: DataStore)
		return DataStore:SetAsync(key, value)
	end)
end

function DataService.UpdateAsync (self, key, transformFunction, proxy)
	self:DataStoreThrottle(proxy, function (DataStore: DataStore)
		return DataStore:UpdateAsync(key, transformFunction)
	end)
end

function DataService.IncrementAsync (self, key, delta, proxy)
	self:DataStoreThrottle(proxy, function (DataStore: DataStore)
		return DataStore:IncrementAsync(key, delta)
	end)
end

function DataService.proxy (self, callback, onError)
	return {
		callback = callback;

		retries = 0;
		shouldRetry = true;

		onErrorHandler = onError;

		finished = false;

		setFinished = function (self)
			self.finished = true
		end;

		onError = function (self, callback)
			self.onErrorHandler = callback
		end;

		CancelRetry = function (self)
			self.shouldRetry = false
		end;
	}
end

function framework.Fetch (self, key, callback, onError)
	if not callback or typeof(callback) ~= "function" then
		error("Callback invalid")
	end
	
	if self:InRetry() then
		-- This means its running in the ScheduleRetry functionality
		-- TODO: Figure out if connection was already established
		if self:DebugEnabled() == "internal" then
			warn("Exiting Connect:Fetch - within ScheduleRetry")
		end

		return self:InRetryResponse()
	end
	
	local proxy: module = self.DataService:proxy(callback, onError)
	return proxy, self.DataService:GetAsync(key, proxy)
end

function framework.Store (self, key, value, callback, onError)
	if not callback or typeof(callback) ~= "function" then
		error("Callback invalid")
	end
	
	if self:InRetry() then
		-- This means its running in the ScheduleRetry functionality
		-- TODO: Figure out if connection was already established
		if self:DebugEnabled() == "internal" then
			warn("Exiting Connect:Store - within ScheduleRetry")
		end

		return self:InRetryResponse()
	end
	
	local proxy: module = self.DataService:proxy(callback, onError)
	return proxy, self.DataService:SetAsync(key, value, proxy)
end

function framework.UseDataStore (self, name, scope)
	self.DataService.DataStore = function (self)
		return DataStoreService:GetDataStore(name, scope)
	end
end

framework.DataService = DataService
return framework
