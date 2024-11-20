-- not tested this yet!

return function (framework, Player)
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

        onDied = nil,

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

            return self, self.Humanoid, self.HumanoidRootPart
        end,

        wait = function (self)
            if self.HumanoidRootPart and self.HumanoidRootPart:IsDescendantOf(game.Workspace) then
                return self
            end

            repeat task.wait() until self.Humanoid and self.HumanoidRootPart and self.HumanoidRootPart:IsDescendantOf(game.Workspace) return self
        end,

        ready = function (self, callback)
            if not callback then
                return self:wait()
            end
        
            self.onRiggedCallback = callback
            return self;
        end,

        added = function (self, callback)
            if not callback then
                self.onAddedCallback = true
                return self:wait()
            end

            self.onAddedCallback = callback
            return self;
        end,

        finished = function (self)
            local proxy = self

            if self.onRiggedCallback and self:wait() then
                if type(self.onRiggedCallback) == "string" then
                    local Event = framework:event()
                    Event:dispatch(self.onRiggedCallback, self, self.Humanoid, self.HumanoidRootPart)    
                end

                if type(self.onRiggedCallback) == "function" then
                    self.onRiggedCallback(self, self.Humanoid, self.HumanoidRootPart)
                end
            end

            if self.onAddedCallback then
                if not self.onRiggedCallback then
                    self:wait()
                end

                if table.find({"function", "string"}, type(proxy.onAddedCallback)) then
                    framework:create(self.Player.UserId, self.Player.CharacterAdded, function (self, Character)
                        if type(proxy.onAddedCallback) == "string" then
                            local Event = framework:event()
                            return proxy:root(Player), proxy:wait(), Event:dispatch(proxy.onAddedCallback, proxy, proxy.Humanoid, proxy.HumanoidRootPart)
                        end

                        if type(proxy.onAddedCallback) == "function" then
                            return proxy:root(Player), proxy:wait(), proxy.onAddedCallback(proxy, proxy.Humanoid, proxy.HumanoidRootPart)
                        end
                    end)
                end

                if type(proxy.onAddedCallback) == "string" then
                    local Event = framework:event()
                    return Event:dispatch(self.onAddedCallback, self, self.Humanoid, self.HumanoidRootPart)
                end


                if type(proxy.onAddedCallback) == "function" then
                    return self.onAddedCallback(self, self.Humanoid, self.HumanoidRootPart)
                end
            end
        end,

        -- GENERAL FUNCTIONS
        -- These functions must first call self:wait()
        
        use = function (self, instance: Instance, options: {})
            self:wait()
            
            if instance:IsA('Accessory') then
                for prop,value in next, options do
                    instance[prop] = value
                end
                
                instance.Parent = self.Character
            end

            if instance:IsA('IKControl') then
                for prop,value in next, options do
                    instance[prop] = if type(value) == 'string' then self.Character:FindFirstChild(value) else value
                end

                instance.Parent = self.Humanoid
            end
        end,

        died = function (self, eventName, callback)
            self:wait()

            if type(eventName) ~= "string" and type(eventName) ~= "function" and eventName then
                return warn('Incorrect DataType passed ConnectHumanoid:died')
            end

            if not callback then
                callback = eventName
                eventName = nil
            end

            if not callback then
                return self, self.Humanoid.Died:Wait()
            end

            local rig = self

            if not self.onAddedCallback or not self.onDied then
                if not (self.onRiggedCallback and not self.onAddedCallback) then
                    framework:create(self.Player.UserId, self.Player.CharacterAdded, function (self, Character)
                        rig:root(self.Player)
                        rig:died(eventName, callback)
                    end)
                end
            end

            self.onDied = framework:create(self.Humanoid.Died, function (connection)
                if type(callback) == "string" then
                    local Event = framework:event(if type(eventName) == "string" then eventName else nil)
                    return Event:dispatch(callback, self)
                end
                
                return callback(self)
            end)

            return self
        end,

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

    local Rig, Humanoid, HumanoidRootPart = proxy:root()

    setmetatable(proxy, {
        __index = function (self, key)
            if (table.find({'onRiggedCallback', 'onAddedCallback', 'onDied'}, key)) then
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

                return ref
            end
        end,

        __newindex = function (self, key, value)
            return rawset(self, key, value)
        end,
    })

    return proxy, Humanoid, HumanoidRootPart, task.defer(function ()
        proxy:finished()
    end)
end
