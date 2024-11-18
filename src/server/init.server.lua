local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

-- Create the Event
local Event = Connect:event("PlayerAdded")

Event:requested(function (self, ...)
    print(`Event requested:`, ...)
end)

Connect:create('PlayerAdded', function (self, Player)
    Event:broadcast(Player)

    local Rig = Connect:humanoid(Player)
    
    Rig:ready(function (self, Humanoid, HumanoidRootPart)
        print('READY - This runs once', self)

        HumanoidRootPart:SetNetworkOwner(nil)
        HumanoidRootPart:ApplyImpulse(Vector3.new(1000, 1000, 1000))

        task.delay(3, HumanoidRootPart.SetNetworkOwner, HumanoidRootPart, Player)
    end)

    Rig:added(function (self, Humanoid, HumanoidRootPart)
        print('ADDED - Each time the Rig is refreshed', self)
        task.delay(1, self.damage, self, 47)

        task.wait(3)

        self:pivot(CFrame.new(0, 10, 0))
    end)

    Connect:humanoid(Player):added(function (Character)
        print("ADDED 2", Character)
    end)
end)