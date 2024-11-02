local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
Connect:UseDataStore(5)

-- Create the session
local Session = Connect:Session()

-- Register a global onUpdate handler
Session:onUpdate(function (self, key, value)
    -- print(`{key}: {value}`)
end)

-- Register the PlayerAdded Connection
local PlayerAdded = Connect:create("PlayerAdded", function (self, Player)
    Connect:create(Player, "CharacterAdded", function (self, Character)
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Connect:create(HumanoidRootPart, "RunService.Stepped", function (self, runTime, step)
            print(HumanoidRootPart.Position)
        end)
    end)

    Connect:create(Player, "CharacterAdded", function (self, Character)
        Connect:create(Character, "RunService.Stepped", function (self, step)
            -- This will only run while the character exists, 
            -- and automatically disconnects when the character no longer exists
        end)
    end)

    -- Create a Key for the Player's points
    local key = Session:key(Player.UserId, "Points")

    -- Register a Key specific onUpdate handler
    Session:onUpdate(key, function (self, value)

    end)

    -- Fetch the player's saved data for this key
    local DataStoreRequest = Connect:fetch(key, function (self, response)
        Connect.tick(1, function ()
            -- print(self:finished())
            -- Increase the points each second
            Session:store(key, (Session:Get(key) or response or 0) + 1)
        end, function ()
            -- Cancel running if the player has left
            return not (Player and Player.Parent)
        end)
    end)

    DataStoreRequest:onError(function (self, err)
        warn(err)

        if (self.retries == 5) then
            self:CancelRetry()
        end
    end)

    DataStoreRequest:sync()

    print("Data loaded!")
end)

-- Register the PlayerRemoving connection
Connect:create("Players.PlayerRemoving", function (self, Player)
    local key = Session:key(Player.UserId, "Points")
    local value = Session:find(key)
    
    -- Save the player's points
    Connect:store(key, value, function (self, response)
        -- Remove the key from session storage, it's no longer needed
        Session:remove(key)
    end)
end)

