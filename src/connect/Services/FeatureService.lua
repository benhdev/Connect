-- --!strict
-- type table<T> = { [T] : any }

-- type mt = { [string]: (...any?) -> ...any? }
-- type module = typeof(setmetatable({}, {} :: mt)) & table<any>
-- type array = table<number>
-- type object = table<string>

-- local framework: module = {} :: module
-- local FeatureService: module = { register = {}; enabledClient = {} } :: module

-- local MessagingService = game:GetService("MessagingService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local RunService = game:GetService("RunService")

-- function FeatureService.DataStoreKey (self, feature: string)
-- 	return script.Name .. ".features." .. feature
-- end

-- function FeatureService.Register(self, feature)
-- 	if not self.register[feature.name] then
-- 		self.register[feature.name] = {}
-- 	end
	
-- 	if feature.onEnableHandler or feature.onDisableHandler then
-- 		self.register[feature.name][feature.uuid] = feature
-- 	end
-- end

-- function FeatureService.Status (self, feature: string)
-- 	local function callback ()
-- 		print("Not deployed")
-- 	end
	
-- 	if self.subscription then
-- 		self.subscription:Disconnect()
-- 	end
	
-- 	self.subscription = MessagingService:SubscribeAsync("FeatureService.features.response", function (info)
-- 		if not info.Data then
-- 			self.subscription:Disconnect()
-- 			callback()
-- 		end
-- 	end)
	
-- 	task.delay(30, function ()
-- 		if self.subscription then
-- 			self.subscription:Disconnect()
-- 		end
-- 	end)
		
-- 	MessagingService:PublishAsync("FeatureService.subscription", "status." .. feature)
-- end

-- function FeatureService.proxy (self, name, callback, uuid, onDisable)
-- 	return {
-- 		name = name;
-- 		uuid = uuid;
		
-- 		callback = callback;
		
-- 		onDisableHandler = onDisable;
		
-- 		onDisable = function (self, callback)
-- 			if typeof(callback) ~= "function" then
-- 				error("Invalid type for onDisableHandler: Must be function")
-- 			end

-- 			self.onDisableHandler = callback
-- 			framework.FeatureService:Register(self)
-- 		end;
		
-- 		run = function (self)
-- 			return self:callback()
-- 		end;
		
-- 		onEnable = function (self, callback)
-- 			if typeof(callback) ~= "function" then
-- 				error("Invalid type for onEnableHandler: Must be function")
-- 			end
			
-- 			self.onEnableHandler = callback
-- 			framework.FeatureService:Register(self)
-- 		end;
-- 	}
-- end

-- function framework.IsFeatureEnabled (self, proxy, callback)
-- 	if RunService:IsServer() then
-- 		self:Fetch(self.FeatureService:DataStoreKey(proxy.name), function (self, result)
-- 			return callback(proxy, result)
-- 		end)
-- 	end
	
-- 	if RunService:IsClient() then
-- 		-- TODO: Need to fix this and make it work
-- 		return self.FeatureService.isEnabledRemote:InvokeServer(proxy, callback)
-- 		--return callback(proxy, if self.FeatureService.enabledClient[proxy.name] then true else false)
-- 	end
-- end

-- function framework.Feature (self, name: string, callback)
-- 	if typeof(callback) ~= "function" then
-- 		error("Invalid type for feature callback: Must be function")
-- 	end
	
-- 	-- This needs to be changed as can create memory leak 
-- 	-- if the feature is defined in a loop
-- 	if not self.FeatureService.register[name] then
-- 		self.FeatureService.register[name] = {}
-- 	end
	
-- 	local proxy = self.FeatureService:proxy(name, callback, self:CreateUUID(name, self.FeatureService.register))
-- 	self.FeatureService:Register(proxy)
	
-- 	return proxy, self:IsFeatureEnabled(proxy, function (self, result)
-- 		if result then
-- 			return self:callback()
-- 		end
-- 	end)
-- end

-- function framework.EnableFeature (self, feature: string, shouldRun: boolean?)
-- 	if RunService:IsServer() then
-- 		self:Store(self.FeatureService:DataStoreKey(feature), true, function (self, result)
-- 			if shouldRun then
-- 				MessagingService:PublishAsync("FeatureService.subscription", "enable." .. feature)
-- 			end
-- 		end)
-- 	end
	
-- 	if RunService:IsClient() then
-- 		-- TODO: Handle enabling features on the client
-- 		local feature = self.FeatureService.register[feature]
-- 		if feature then
-- 			for _,feature in next, feature do
-- 				if feature.onEnableHandler and typeof(feature.onEnableHandler) == "function" then
-- 					feature:onEnableHandler()
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- function framework.DisableFeature(self, feature: string)
-- 	if RunService:IsServer() then
-- 		self:Store(self.FeatureService:DataStoreKey(feature), false, function(self, result)
-- 			MessagingService:PublishAsync("FeatureService.subscription", "disable." .. feature)
-- 		end)
-- 	end
	
-- 	if RunService:IsClient() then
-- 		local feature = self.FeatureService.register[feature]
-- 		if feature then
-- 			for _,feature in next, feature do
-- 				if feature.onDisableHandler and typeof(feature.onDisableHandler) == "function" then
-- 					feature:onDisableHandler()
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- if RunService:IsServer() then
-- 	local enableRemote = Instance.new("RemoteEvent")
-- 	enableRemote.Name = "FeatureService.enable"
-- 	enableRemote.Parent = ReplicatedStorage
-- 	FeatureService.enableRemote = enableRemote
	
-- 	local disableRemote = Instance.new("RemoteEvent")
-- 	disableRemote.Name = "FeatureService.disable"
-- 	disableRemote.Parent = ReplicatedStorage
-- 	FeatureService.disableRemote = disableRemote
	
-- 	local isEnabledRemote = Instance.new("RemoteFunction")
-- 	isEnabledRemote.Name = "FeatureService.isEnabled"
-- 	isEnabledRemote.Parent = ReplicatedStorage
-- 	FeatureService.isEnabledRemote = isEnabledRemote
	
-- 	isEnabledRemote.OnServerInvoke = function (Player, proxy, callback)
-- 		return 	
-- 	end
	
-- 	task.defer(function ()
-- 		MessagingService:SubscribeAsync("FeatureService.subscription", function (message)
-- 			local messageData = message.Data:split(".")
			
-- 			local option = messageData[1]
-- 			local featureName = if #messageData > 2 then table.remove(messageData, 1) and table.concat(messageData, ".") else messageData[2]
-- 			local register = framework.FeatureService.register[featureName]
			
-- 			if option == "status" then
-- 				return MessagingService:PublishAsync("FeatureService.features.response", if register then true else false)
-- 			end

-- 			if register then
-- 				for _,feature in next, register do
-- 					if option == "enable" and feature.onEnableHandler and typeof(feature.onEnableHandler) == "function" then
-- 						feature:onEnableHandler()
-- 						enableRemote:FireAllClients(featureName)
-- 					end
					
-- 					if option == "disable" and feature.onDisableHandler and typeof(feature.onDisableHandler) == "function" then
-- 						feature:onDisableHandler()
-- 						disableRemote:FireAllClients(featureName)
-- 					end
-- 				end
-- 			end
-- 		end)
-- 	end)
-- end

-- if RunService:IsClient() then
-- 	-- TODO: This might need changing
-- 	local enableRemote = ReplicatedStorage:WaitForChild("FeatureService.enable")
-- 	local disableRemote = ReplicatedStorage:WaitForChild("FeatureService.disable")
-- 	local isEnabledRemote = ReplicatedStorage:WaitForChild("FeatureService.isEnabled")

-- 	enableRemote.OnClientEvent:Connect(function (feature: string)
-- 		framework:EnableFeature(feature)
-- 	end)
	
-- 	disableRemote.OnClientEvent:Connect(function (feature: string)
-- 		framework:DisableFeature(feature)
-- 	end)
	
-- 	FeatureService.enableRemote = enableRemote
-- 	FeatureService.disableRemote = disableRemote
-- 	FeatureService.isEnabledRemote = isEnabledRemote
-- end

-- framework.FeatureService = FeatureService
-- return framework
return {}