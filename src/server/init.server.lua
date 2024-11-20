local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Event = Connect:event()
local Session = Connect:session()

Event:listen('Humanoid.Ready', function (self, Humanoid, HumanoidRootPart)
    local key = Session:key(self.Player.UserId, 'Joins')
    Session:increment(key, 1)
end)

Event:listen('Humanoid.Added', function (self, Humanoid, HumanoidRootPart)
    local key = Session:key(self.Player.UserId, 'Respawns')
    Session:increment(key, 1)
end)

Event:listen('Humanoid.Died', function (self, Humanoid, HumanoidRootPart)
    local key = Session:key(self.Player.UserId, 'Deaths')
    Session:increment(key, 1)
end)

Connect:create('PlayerAdded', function (self, Player)
    local Rig = Connect:humanoid(Player)
        :added('Humanoid.Added')
        :died('Humanoid.Died')

    local key = Session:key(Player.UserId)

    local DataStoreRequest = Connect:fetch(key, function (self, response)
        local Leaderboard = Instance.new('StringValue')
        Leaderboard.Name = 'leaderstats'

        local Joins = Instance.new('IntValue')
        Joins.Name = 'Joins'

        local Respawns = Instance.new('IntValue')
        Respawns.Name = 'Respawns'
        
        local Deaths = Instance.new('IntValue')
        Deaths.Name = 'Deaths'

        Session:onUpdate(
            Session:key(key, 'Joins'),
            function (self, value)
                Joins.Value = value
            end
        )

        Session:onUpdate(
            Session:key(key, 'Respawns'),
            function (self, value)
                Respawns.Value = value
            end
        )

        Session:onUpdate(
            Session:key(key, 'Deaths'),
            function (self, value)
                Deaths.Value = value
            end
        )

        Session:store(Session:key(key, 'Joins'), (response and response.Joins) or 0)
        Session:store(Session:key(key, 'Respawns'), (response and response.Respawns) or 0)
        Session:store(Session:key(key, 'Deaths'), (response and response.Deaths) or 0)

        Joins.Parent = Leaderboard
        Respawns.Parent = Leaderboard
        Deaths.Parent = Leaderboard

        Leaderboard.Parent = Player
    end)

    if DataStoreRequest:sync() then
        Connect:humanoid(Player):ready('Humanoid.Ready')
    end
end)

Connect:create('PlayerRemoving', function (self, Player)
    local key = Session:key(Player.UserId)
    local value = Session:get(key)

    Connect:store(key, value, function (self, response)
        if response then
            Session:remove(key)
        end

        print(response)
    end)
end)
