local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

local part = workspace:WaitForChild("Part", 5)

-- Create the session
local Session = Connect:session()
local Event = Connect:event()

local Prompt = Connect:prompt(part)

local connection = Prompt:once("do something once", function (self, Player)
    print("triggered once")
end)

connection:onDisconnect(function (self)
    -- disable the default functionality
    local connection = Prompt:once("do something once again", function (self, Player)
        print("triggered once again")
    end)
end)