local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

-- Create the session
local Session = Connect:session()
local Event = Connect:event()

Event:listen("fetch", function (Player, key)
    -- Fetch the player's saved data for this key
    return Connect:fetch(key, function (self, response)
        Connect.tick(function (i)
            -- Increase the points each second
            Session:update(key, (Session:find(key) or response or 0) + 1)
        end, function ()
            -- Cancel running if the player has left
            return not (Player and Player.Parent)
        end)
    end)
end)

Event:listen("createLeaderboard", function (key)
    -- Create the leaderboard
    local Leaderstats = Instance.new("StringValue")
    Leaderstats.Name = "leaderstats"

    -- Create the points value for the leaderboard
    local Points = Instance.new("IntValue")
    Points.Name = "Points"

    -- Register a Key specific onUpdate handler
    Session:onUpdate(key, function (self, value)
        Points.Value = value
    end)

    return Leaderstats, Points
end)

-- Register the PlayerAdded Connection
local connection = Connect:create("PlayerAdded", function (self, Player)
    -- Create a Key for the Player's points
    local key = Session:key(Player.UserId, "Points")

    local Leaderstats, Points = Event:fire("createLeaderboard", key)

    local DataStoreRequest = Event:fire("fetch", Player, key)
    -- Wait for the DataStoreRequest to finish
    DataStoreRequest:sync()

    Points.Parent = Leaderstats
    Leaderstats.Parent = Player
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

-- Connect:DebugEnabled("internal")