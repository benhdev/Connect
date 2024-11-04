local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

-- Create the session
local Session = Connect:session()
local Event = Connect:event()

-- Register the PlayerAdded Connection
local connection = Connect:create("PlayerAdded", function (self, Player)
    Event:dispatch("fetch", Player)

    Connect:create(Player, "CharacterAdded", function (self, Character)
        local Stepped = Connect:create(Character, "RunService.Stepped", function (self, runTime, step)
            print("step")
            if self:CurrentCycle() == 100 then
                self:Disconnect()
            end
        end)

        Stepped:onDisconnect(function (self)
            print("Stepped disconnected!")
            print("Average run time:", self:AverageRunTime())
        end)
    end)
end)

-- Register the PlayerRemoving connection
Connect:create("PlayerRemoving", function (self, Player)
    Event:dispatch("store", Player)
end)

-- Connect:DebugEnabled("internal")
Connect:Counter()