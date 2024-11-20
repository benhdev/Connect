-- local ReplicatedStorage = game:GetService('ReplicatedStorage')
-- local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

-- local Event = Connect:event()
-- local Session = Connect:session()

-- Event:listen('Humanoid.Ready', function (Rig)
--     print(`{Rig.Name} is ready!`)

--     local key = Session:key(Rig.Player.UserId, 'Points')

--     local DataStoreRequest = Connect:fetch(key, function (self, response)
-- 		print('Points', response)
-- 		local Leaderboard = Instance.new('StringValue')
-- 		Leaderboard.Name = 'leaderstats'
		
-- 		local Points = Instance.new('IntValue')
-- 		Points.Name = 'Points'
-- 		Points.Parent = Leaderboard

--         Session:onUpdate(key, function (self, value)
--             Points.Value = value or 0
--         end)
		
--         Session:store(key, response)
-- 		Leaderboard.Parent = Rig.Player
--     end)

--     DataStoreRequest:sync()
-- end)

-- Event:listen('Humanoid.Added', function (Rig)
--     print(`{Rig.Name} was added!`)

--     local key = Session:key(Rig.Player.UserId, 'Points')
--     local value = Session:get(key) or 0

--     Rig:use(Instance.new('IKControl'), {
--         test = true
--     })

--     Session:update(key, value + 1)
-- end)

-- Connect:create('PlayerAdded', function (self, Player)
--     Connect:humanoid(Player):ready('Humanoid.Ready')
--     Connect:humanoid(Player):added('Humanoid.Added')
-- end)

-- Connect:create('PlayerRemoving', function (self, Player)
--     local key = Session:key(Player.UserId, 'Points')
--     Connect:store(key, Session:get(key), function (self, response)
--         print(response)
--     end)
-- end)