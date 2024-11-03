local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

-- Create the session
local Session = Connect:session()
local Event = Connect:event()

Event:listen("fetch", function (Player)
    local key = Session:key(Player.UserId, "Points")
    -- Dispatch the Event which creates the leaderboard
    local Leaderstats, Points = Event:dispatch("createLeaderboard", key)
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

Event:listen("fetch.finished", function ()
    print("fetch.finished")
end)

Event:listen('store', function (Player)
    local key = Session:key(Player.UserId, "Points")
    local value = Session:find(key)

    -- Save the player's points
    local DataStoreRequest = Connect:store(key, value, function (self, response)
        -- Remove the key from session storage, it's no longer needed
        Session:remove(key)
    end)

    DataStoreRequest:sync()
end)

Event:listen("store.finished", function ()
    print(`store.finished`)
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

Event:listen("createLeaderboard.finished", function ()
    print("createLeaderboard.finished")
end)