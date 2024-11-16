local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

-- Create the Event
local Event = Connect:event("PlayerAdded")

Event:requested(function (self, ...)
    print(`Event requested:`, ...)
end)

Connect:create('PlayerAdded', function (self, Player)
    Event:broadcast(Player)
end)

-- -- Register the PlayerAdded Connection
-- local connection = Connect:create('PlayerAdded', function (self, Player)
--     Event:dispatch('fetch', Player)

--     Connect:create(Player, 'CharacterAdded', function (self, Character)
--         local Stepped = Connect:create(Character, 'RunService.Stepped', function (self, runTime, step)
--             print('step')
--             if self:CurrentCycle() == 100 then
--                 print('here')
--                 Event:broadcast(100)
--                 self:Disconnect()
--             end
--         end)

--         Stepped:onDisconnect(function (self)
--             print('Stepped disconnected!')
--             print('Average run time:', self:AverageRunTime())
--         end)
--     end)
-- end)

-- -- Register the PlayerRemoving connection
-- Connect:create('PlayerRemoving', function (self, Player)
--     Event:dispatch('store', Player)
-- end)

-- -- Connect:DebugEnabled('internal')
-- Connect:Counter()

-- -- Touch debounce
-- Connect:create(Doorway.Portal, 'Touched', function (self, hit)
-- 	if not open then return end
	
-- 	local Player = game.Players:GetPlayerFromCharacter(hit.Parent)
-- 	if not Player then return end
	
-- 	if not Connect:Thread(Session:key(Player.UserId, 'teleport')) then
-- 		local t = coroutine.create(function ()
-- 			if Player and Player.Character then
-- 				Player.Character:MoveTo(game.Workspace:FindFirstChild('PortalDestination').Position + Vector3.new(0, 11, 0))
-- 			end
-- 		end)
		
-- 		Connect:Thread(Session:key(Player.UserId, 'teleport'), t)
-- 		coroutine.resume(t)
-- 	end
-- end)