-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
-- Connect:UseDataStore(4)

-- local Session = Connect:Session()

-- Session:onUpdate(function (self, key, value)
--     print(`{key}: {value}`)
-- end)

-- Connect.new("PlayerAdded", function (self, Player)
--     local key = Session:Key(Player.UserId)
--     print(key);

-- 	local leaderstats = Instance.new("IntValue")
-- 	leaderstats.Name = "leaderstats"
-- 	leaderstats.Parent = Player

--     local DataStoreRequest = Connect:Fetch(Player.UserId, function (self, response)
--         local Time = Instance.new("StringValue")
-- 		Time.Name = "Time"

-- 		Session:onUpdate(key, function (self, value)
--             local value = tonumber(value)

--             local f,dv
--             if (value >= 86400) then
--                 dv = math.floor(value/86400)
--                 f = dv .. " day" .. (if tonumber(dv) == 1 then "" else "s") .. " "
--             end

--             local m = value
--             if (f and dv) then
--                 m = value - (86400 * dv)
--             end

--             local t = {" min", " hour"}
--             local e = math.min(#t, math.floor(math.log(m, 60)))
--             local d = t[e] or (if m == 0 then "" else " sec")

--             local v = (f or "") .. (if m and m > 0 then math.floor(m / (60 ^ e)) else "")
--             Time.Value = v .. d .. (if (not tonumber(m) or tonumber(m) <= 1) then "" else "s")
--         end)
        
--         Connect.tick(1, function ()
--             -- need to cancel this when the player
--             -- has left the game
--             print(key)
--             print(Session:Get(key))
--             print(response);

--             local value = (Session:Get(key) or (response or 0)) + 1

--             if (value % 180 == 0) then
--                 -- autosave every 3 minutes
--                 Connect:Store(Player.UserId, value, function (self, response)
--                     return response
--                 end)
--             end

--             Session:Update(key, value)
--         end, function ()
--             -- Cancel running if the player has left
--             return not (Player and Player.Parent)
--         end)

--         Time.Parent = leaderstats
-- 	end)
	
-- 	DataStoreRequest:onError(function (self, err)
-- 		warn(err)
		
-- 		if self.retries == 5 then
-- 			self:CancelRetry()
-- 		end
-- 	end)
-- end)

-- Connect:once("Players.PlayerRemoving", function (self, Player)
--     local key = Session:Key(Player.UserId)

-- 	local value = Session:Get(key)
-- 	Session:Remove(key)

-- 	local DataStoreRequest = Connect:Store(Player.UserId, value, function (self, response)
--         print(response)
--         return response
--     end)

--     DataStoreRequest:onError(function (self, err)
--         warn(err)
    
--         if self.retries == 5 then
--             self:CancelRetry()
--         end
--     end)

--     print(`Here: {DataStoreRequest.response}`);
--     DataStoreRequest:sync()
--     print(`Done: {DataStoreRequest.response}`);
-- end)

-- game:BindToClose(function ()
--     -- this is problematic as Session.Data is nested
--     for userId, userData in next, Session.Data do
--         Session:Remove(userId)

--         local DataStoreRequest = Connect:Store(userId, userData, function (self, response)
--             return response
--         end)

--         DataStoreRequest:onError(function (self, err)
--             warn(err)
		
--             if self.retries == 3 then
--                 self:CancelRetry()
--             end
--         end)

--         DataStoreRequest:sync()
--     end
-- end)