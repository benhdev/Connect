local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
Connect:UseDataStore(5)

-- Create the session
local Session = Connect:Session()

-- Register a global onUpdate handler
Session:onUpdate(function (self, key, value)
    print(`{key}: {value}`)
end)

-- Register the PlayerAdded Connection
Connect:once("Players.PlayerAdded", function (self, Player)
    -- Create a Key for the Player's points
    local key = Session:Key(Player.UserId, "Points")

    -- Register a Key specific onUpdate handler
    Session:onUpdate(key, function (self, value)

    end)

    -- Fetch the player's saved data for this key
    Connect:fetch(key, function (self, response)
        Connect.tick(1, function ()
            -- Increase the points each second
            Session:Update(key, (Session:Get(key) or response or 0) + 1)
        end)
    end)
end)

-- Register the PlayerRemoving connection
Connect:once("Players.PlayerRemoving", function (self, Player)
    local key = Session:Key(Player.UserId, "Points")
    local value = Session:Get(key)
    
    -- Save the player's points
    Connect:store(key, value, function (self, response)
        -- Remove the key from session storage, it's no longer needed
        Session:Remove(key)
    end)
end)