local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

print("here1")

local part1 = workspace:WaitForChild("Part1", 5)
local part2 = workspace:WaitForChild("Part2", 5)

print("here")

-- Create the session
local Session = Connect:session()
local Event = Connect:event()


local Prompt = Connect:prompt()

local connection = Prompt:once(part1, "do something once", function (self, Player)
    print("triggered once")
end)

connection:onDisconnect(function (self)
    -- disable the default functionality
    local connection = Prompt:once(part2, "do something once again", function (self, Player)
        print("triggered once again")
    end)
end)

print("here")