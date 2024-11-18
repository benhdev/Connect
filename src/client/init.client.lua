local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

-- Create the Event
local Event = Connect:event('PlayerAdded')

Event:replicated(function (self, ...)
    print(`{Event.name} was replicated!`, ...)
    Event:request('testing...')
end)