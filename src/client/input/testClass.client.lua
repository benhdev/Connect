--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local HumanoidClass = Connect:WaitForClass('Humanoid')

local FolderClass = Connect:class('Folder')
FolderClass.Instance = true

FolderClass.Children = {
    FolderClass.new()
}

for i = 1, 9 do
    local Folder = FolderClass.new()
    Folder.Name = `Folder{i}`

    table.insert(HumanoidClass.Children, Folder)
end


local Humanoid = HumanoidClass.new()
Humanoid.Parent = ReplicatedStorage

Humanoid:damage(100)

print(Humanoid)