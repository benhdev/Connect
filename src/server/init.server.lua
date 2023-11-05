local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
local Session = Connect:Session()

Connect.new("Players.PlayerAdded", function (self, Player)
    local key = Session:Key(Player.UserId)

	local leaderstats = Instance.new("IntValue")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

    local DataStoreRequest = Connect:Fetch(Player.UserId, function (self, response)
        local Time = Instance.new("StringValue")
		Time.Name = "Time"

		Session:onUpdate(key, function (self, value)
            local value = tonumber(value)

            local f,dv
            if (value >= 86400) then
                dv = math.floor(value/86400)
                f = dv .. " days "
            end

            local m = value
            if (f and dv) then
                m = value - (86400 * dv)
            end

            local t = {" mins", " hours"}
            local e = math.min(#t, math.floor(math.log(m, 60)))
            local d = t[e] or " secs"

            local v = (f or "") .. math.floor(m / (60 ^ e)) .. d
            Time.Value = v
        end)
        
        Connect.tick(1, function ()
            local value = (Session:Get(key) or (response or 0)) + 1

            if (value % 180 == 0) then
                Connect:Store(Player.UserId, value, function (self, response)
                    return response
                end)
            end

            Session:Update(key, value)
        end)

        Time.Parent = leaderstats
	end)
	
	DataStoreRequest:onError(function (self, err)
		warn(err)
		
		if self.retries == 5 then
			self:CancelRetry()
		end
	end)
end)

Connect.new("Players.PlayerRemoving", function (self, Player)
    local key = Session:Key(Player.UserId)

    local DataStoreRequest = Connect:Store(Player.UserId, Session:Get(key), function (self, response)
        return response
    end)

    DataStoreRequest:onError(function (self, err)
        warn(err)
    
        if self.retries == 5 then
            self:CancelRetry()
        end
    end)
end)

game:BindToClose(function ()
    for userId, userData in next, Session.Data do
        local DataStoreRequest = Connect:Store(userId, userData, function (self, response)
            return response
        end)

        DataStoreRequest:onError(function (self, err)
            warn(err)
		
            if self.retries == 5 then
                self:CancelRetry()
            end
        end)
    end
end)