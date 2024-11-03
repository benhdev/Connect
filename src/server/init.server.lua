local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
Connect:UseDataStore(7)

-- Create the session
local Session = Connect:session()

-- Register a global onUpdate handler
Session:onUpdate(function (self, key, value)
    -- print(`{key}: {value}`)
end)

-- Register the PlayerAdded Connection
local connection = Connect:create("PlayerAdded", function (self, Player)
    -- Create the leaderboard
    local Leaderstats = Instance.new("StringValue")
    Leaderstats.Name = "leaderstats"

    -- Create the points value for the leaderboard
    local Points = Instance.new("IntValue")
    Points.Name = "Points"

    -- Create a Key for the Player's points
    local key = Session:key(Player.UserId, "Points")

    -- Register a Key specific onUpdate handler
    Session:onUpdate(key, function (self, value)
        Points.Value = value
    end)

    -- Fetch the player's saved data for this key
    local DataStoreRequest = Connect:fetch(key, function (self, response)
        Connect.tick(function (i)
            -- Increase the points each second
            Session:update(key, (Session:find(key) or response or 0) + 1)
        end, function ()
            -- Cancel running if the player has left
            return not (Player and Player.Parent)
        end)
    end)

    -- Wait for the DataStoreRequest to finish
    DataStoreRequest:sync()

    Points.Parent = Leaderstats
    Leaderstats.Parent = Player
end)

connection:onDisconnect(function (self)

end)

Connect.tick(5, function ()

end, function () 
    return not connection.Connected
end)

-- Register the PlayerRemoving connection
Connect:create("PlayerRemoving", function (self, Player)
    local key = Session:key(Player.UserId, "Points")
    local value = Session:find(key)

    -- Save the player's points
    Connect:store(key, value, function (self, response)
        -- Remove the key from session storage, it's no longer needed
        Session:remove(key)
    end)
end)