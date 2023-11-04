local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
local Session = Connect:Session()

Connect.new("Players.PlayerAdded", function (self, Player)
    local key = Session:Key(Player.UserId, "Time")

	local leaderstats = Instance.new("IntValue")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

    local DataStoreRequest = Connect:Fetch(Player.UserId, function (self, response)
        local Time = Instance.new("StringValue")
		Time.Name = "Time"

		Session:onUpdate(key, function (self, value)
			local seconds = value
			local mins = math.floor(seconds/60)
			local hours = math.floor(mins/60)
			local days = math.floor(hours/24)
            
            local newValue
            if (mins >= 1) then
                newValue = mins .. " mins"
            else
                newValue = seconds .. " secs"
            end

            if (hours >= 1) then
                newValue = hours .. " hours"
            end

            if days >= 1 then
                newValue = days .. " days"
            end

            Time.Value = newValue
        end)

		Time.Parent = leaderstats
        Session:Update(key, response or 0)
        
        Connect.tick(1, function ()
            local currentValue = Session:Get(key)
            Session:Update(key, currentValue + 1)
        end)
	end)
	
	DataStoreRequest:onError(function (self, err)
		warn(err)
		
		if self.retries == 5 then
			self:CancelRetry()
		end
	end)
end)

Connect.new("Players.PlayerRemoving", function (self, Player)
    local key = Session:Key(Player.UserId, "Time")

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
        print("userData.Time:", userData.Time)

        local DataStoreRequest = Connect:Store(userId, userData.Time, function (self, response)
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