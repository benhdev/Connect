-- not tested this yet!

return {
    humanoid = function (self, Player)
        local framework = self

        if not Player then
            error("No Player found for Humanoid")
        end

        local proxy = {
            Player = Player or game.Players.LocalPlayer or nil,

            Character = Player.Character or Player.CharacterAdded:Wait(),

            Humanoid = nil,

            HumanoidRootPart = nil,

            onAddedCallback = nil,

            onRiggedCallback = nil,

            -- CORE FUNCTIONS

            root = function (self, Player)
                if not Player then Player = self.Player else self.Player = Player end

                local Character = Player.Character
                if not Character then 
                    return
                end

                self.Character = Character
                self.Humanoid = Character:WaitForChild('Humanoid', 3)
                self.HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 3)

                return self.Humanoid, self.HumanoidRootPart
            end,

            wait = function (self)
                if self.HumanoidRootPart and self.HumanoidRootPart:IsDescendantOf(game.Workspace) then
                    return true
                end

                repeat task.wait() until self.Humanoid and self.HumanoidRootPart and self.HumanoidRootPart:IsDescendantOf(game.Workspace) return true
            end,

            ready = function (self, callback)
                if not callback then
                    return self:wait()
                end
            
                self.onRiggedCallback = callback
            end,

            added = function (self, callback)
                if not callback then
                    self:wait()
                end

                self.onAddedCallback = callback
            end,

            finished = function (self)
                local proxy = self

                if self.onRiggedCallback and self:wait() then
                    self.onRiggedCallback(self, self.Humanoid, self.HumanoidRootPart)
                end

                if self.onAddedCallback then
                    if not self.onRiggedCallback then
                        self:wait()
                    end

                    framework:create(self.Player.UserId, self.Player.CharacterAdded, function (self, Character)
                        return proxy:root(Player), proxy:wait(), proxy.onAddedCallback(proxy, proxy.Humanoid, proxy.HumanoidRootPart)
                    end)

                    self.onAddedCallback(self, self.Humanoid, self.HumanoidRootPart)
                end
            end,

            -- GENERAL FUNCTIONS
            -- These functions must first call self:wait()

            damage = function  (self, amount: number, takeDamage: boolean)
                self:wait()

                if takeDamage then
                    self.Humanoid:TakeDamage(amount)
                end

                self.Humanoid.Health -= (amount or 100)
            end,

            pivot = function (self, target: CFrame)
                return self:wait(), self:PivotTo(target)
            end,

            animate = function (self)
                self:wait()
            end,
        }

        setmetatable(proxy, {
            __index = function (self, key)
                if (table.find({'onRiggedCallback', 'onAddedCallback'}, key)) then
                    return
                end

                if rawget(self, 'Character') then
                    local ref = self.Character[key]
                    if not ref then 
                        return 
                    end

                    if type(ref) == "function" then
                        return function (this, arg)
                            local success, result = pcall(ref, this.Character, arg)
                            
                            if not success then
                                warn(result)
                            end

                            return success and result
                        end
                    end

                end
            end,
        })

        local Humanoid, HumanoidRootPart = proxy:root()
        return proxy, Humanoid, HumanoidRootPart, task.defer(function ()
            proxy:finished()
        end)
    end
}

-- An example would be

-- local Rig, Humanoid, HumanoidRootPart = Connect:humanoid(Player)

-- print(Rig, Rig.Humanoid, Rig.HumanoidRootPart, Humanoid, HumanoidRootPart)

-- -- No need to pass player in LocalScripts
-- local Rig = Connect:humanoid()
-- local Camera = Connect:camera()

-- local Humanoid, HumanoidRootPart = Rig:root()

-- local Tween = Camera:tween(Rig, {

-- })

-- Refresh the humanoid state by passing the player into the root method

-- local Rig, Humanoid = Connect:humanoid(Player)
-- ...
-- Rig:root(Player)
-- print(Rig.HumanoidRootPart.Position)
