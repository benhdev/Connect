local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Client = Connect:client()
local Event = Connect:event('KeyboardEvent')

Event:listen('handle', function (inputObject: InputObject, gameProcessed: boolean)
    local Rig = Client:humanoid()
    if Rig:ready() then
        print('Q Pressed')
    end
end)