--!strict
game:WaitForChild('ReplicatedStorage')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Humanoid = Connect:class('Humanoid')

Humanoid.Instance = true -- or string for ClassName if using a custom class name in the above line
Humanoid.Health = 47
Humanoid.MaxHealth = 133

function Humanoid:damage (damage)
    self.Health -= damage
end

local newHumanoid = Humanoid.new()
newHumanoid.Parent = ReplicatedStorage