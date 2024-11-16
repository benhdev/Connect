local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

-- Create the Event
local Event = Connect:event('PlayerAdded')

Event:replicated(function (self, ...)
    print(`{Event.name} was replicated!`, ...)
    Event:request('testing...')
end)

-- local part = workspace:WaitForChild('Part', 5)

-- local Prompt = Connect:prompt(part)

-- local connection = Prompt:once('do something once', function (self, Player)
--     print('triggered once')
-- end)

-- connection:onDisconnect(function (self)
--     -- disable the default functionality
--     local connection = Prompt:once('do something once again', function (self, Player)
--         print('triggered once again')
--     end)
-- end)