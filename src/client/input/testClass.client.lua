--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local HumanoidClass = Connect:WaitForClass('Humanoid')

local FolderClass = Connect:class('Folder')
FolderClass.Instance = true
FolderClass.Name = 'TestFolder'

HumanoidClass.Children = {
    FolderClass.new(),
    FolderClass,
}

local Humanoid = HumanoidClass.new()
Humanoid.Parent = ReplicatedStorage

Humanoid:damage(100)

print(Humanoid)