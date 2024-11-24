local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

-- Create the Client
local Client = Connect:client()

Client:humanoid():ready(function (self, Humanoid, Root)
    print('Client.Rig ready')
end)

Client:humanoid():added():died(function (self, Humanoid, Root)
    print(self.Name, 'died')
end)