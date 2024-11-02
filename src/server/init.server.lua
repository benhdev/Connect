local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
Connect:UseDataStore(7)

-- Create the session
local Session = Connect:session()

-- Register a global onUpdate handler
Session:onUpdate(function (self, key, value)
    print(`{key}: {value}`)
end)

-- Register the PlayerAdded Connection
Connect:create("PlayerAdded", function (self, Player)
    -- Create a Key for the Player's points
    local key = Session:key(Player.UserId, "Points")

    -- Register a Key specific onUpdate handler
    Session:onUpdate(key, function (self, value)
        -- print(`{key}: {value}`)
    end)

    -- Fetch the player's saved data for this key
    local DataStoreRequest = Connect:fetch(key, function (self, response)
        Connect.tick(1, function ()
            -- Increase the points each second
            Session:update(key, (Session:find(key) or response or 0) + 1)
        end, function ()
            -- Cancel running if the player has left
            return not (Player and Player.Parent)
        end)
    end)
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