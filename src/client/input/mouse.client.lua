--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Event = Connect:event('MouseEvent')

Event:listen('handle', function (inputObject, gameProcessed)
    print('click')
end)

Event:listen('handleRight', function (inputObject: InputObject, gameProcessed: boolean)
    print('right click')
end)