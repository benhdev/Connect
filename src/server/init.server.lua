local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local PlayerEvent = Connect:event('Player')

local HumanoidReady = Connect:event()
HumanoidReady:listen('Humanoid.Ready', function (Rig)
    print(`{Rig.Name} is ready!`)
end)

local HumanoidAdded = Connect:event('HumanoidAdded')
HumanoidAdded:listen('handle', function (Rig)
    print(`{Rig.Name} was added!`)
end)

local HumanoidDied = Connect:event('HumanoidDied')
HumanoidDied:listen('handle', function (Rig)
    print(`{Rig.Name} died!`)
end)

-- Connect:create('PlayerAdded', function (self, Player)
--     local Rig = Connect:humanoid(Player)
--         :ready(PlayerEvent)
--         :added(HumanoidAdded)
--         :died(HumanoidDied)
-- end)

Connect:create('PlayerAdded', PlayerEvent)
Connect:create('PlayerRemoving', PlayerEvent, 'store')