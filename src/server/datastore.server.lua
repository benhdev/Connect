-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

-- Connect.new("PlayerAdded", function (self, Player)
-- 	-- Do all DataStore requests at the top
-- 	-- as they do not work within Scheduled Retries
-- 	print("PlayerAdded")
	
-- 	local leaderstats = Instance.new("IntValue")
-- 	leaderstats.Name = "leaderstats"
-- 	leaderstats.Parent = Player
	
-- 	local DataStoreRequest = Connect:Fetch(Player.UserId, function (self, response)
-- 		local Coins = Instance.new("IntValue")
-- 		Coins.Name = "Coins"
-- 		Coins.Value = response or 0
-- 		Coins.Parent = leaderstats
-- 	end)
	
-- 	DataStoreRequest:onError(function (self, err)
-- 		warn(err)
		
-- 		if self.retries == 5 then
-- 			self:CancelRetry()
-- 		end
-- 	end)
	
-- 	local GemsFeature = Connect:Feature("Gems", function (self)
-- 		local feature = self
		
-- 		local DataStoreRequest = Connect:Fetch(Player.UserId .. "Gems", function (self, response)
-- 			local Gems = Instance.new("IntValue")
-- 			Gems.Name = "Gems"
-- 			Gems.Value = response or 0
-- 			Gems.Parent = leaderstats
			
-- 			feature:onDisable(function ()
-- 				Connect:Store(Player.UserId .. "Gems", Gems.Value, function (self, response)
-- 					Gems:Destroy()
-- 				end)
-- 			end)
-- 		end)
-- 	end)
	
-- 	--GemsFeature:onEnable(function (self)
-- 	--	self:run()
-- 	--end)
	
-- 	Connect.new(Player, "CharacterAdded", function (self, Character)
-- 		print("CharacterAdded")
-- 	end)
	
-- end)

-- Connect.new("PlayerRemoving", function (self, Player)
-- 	Connect:Store(Player.UserId, 10, function (self, response)
-- 		print("success")
-- 	end)
-- end)


-- print(Connect.HelperService:FormatNumber(1000000))

-- local nest = Connect.HelperService:Nest({
-- 	playerData = {
-- 		{
-- 			testValue = 6;
-- 			otherValue = 7;
-- 		};
		
-- 		{
-- 			testValue = 4;
-- 			otherValue = 5;
-- 		};
-- 	}
-- })

-- nest:onUpdate(function (self, key, value)
-- 	print("Global update:", key, value)
-- end)

-- nest:onUpdate('playerData.2.testValue', function (self, value)
-- 	print("playerData.2.testValue update:", value)
-- end)

-- nest:Update("hello.my.name.is.web", 5)

-- nest["hello.there"] = 5
-- nest["playerData.2.testValue"] = 9

-- print(nest.Data)