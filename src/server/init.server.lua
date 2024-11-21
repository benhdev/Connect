local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Event = Connect:event()

Event:listen('Humanoid.Ready', function (Rig)
    print(`{Rig.Name} is ready!`)
end)

Event:listen('Humanoid.Added', function (Rig)
    print(`{Rig.Name} was added!`)
end)

Event:listen('Humanoid.Died', function (Rig)
    print(`{Rig.Name} died!`)
end)

Connect:create('PlayerAdded', function (self, Player)
    local Rig = Connect:humanoid(Player)
        :ready('Humanoid.Ready')
        :added('Humanoid.Added')
        :died('Humanoid.Died')
end)