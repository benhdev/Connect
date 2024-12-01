--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Humanoid = Connect:class('Humanoid')

Humanoid.Instance = true -- or string for ClassName if using a custom class name in the above line
Humanoid.Health = 47
Humanoid.MaxHealth = 133

function Humanoid:damage (damage)
    self.Health -= 22
end

local newHumanoid = Humanoid.new()
local newHumanoid2 = Humanoid.new()

newHumanoid2.Health = 100

newHumanoid.Parent = ReplicatedStorage
newHumanoid2.Parent = ReplicatedStorage

newHumanoid2:damage(22)

print(Humanoid, newHumanoid, newHumanoid2)