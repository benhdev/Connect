local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

-- Create the session
local Session = Connect:session()
local Event = Connect:event()

-- Register the PlayerAdded Connection
local connection = Connect:create("PlayerAdded", function (self, Player)
    Event:dispatch("fetch", Player)
end)

-- Register the PlayerRemoving connection
Connect:create("PlayerRemoving", function (self, Player)
    Event:dispatch("store", Player)
end)

-- Connect:DebugEnabled("internal")