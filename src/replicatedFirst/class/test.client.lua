--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local HumanoidClass = Connect:class('Humanoid')

local Humanoid = HumanoidClass.new()
Humanoid.Parent = ReplicatedStorage