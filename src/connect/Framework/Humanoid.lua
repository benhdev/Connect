return function (framework, Player)
    local Player = Player or game.Players.LocalPlayer or error("No Player found for Humanoid")
    
    local proxy = {
        Player = Player,

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

        ready = function (self, eventName, callback)
            if not table.find({"function", "string", "table"}, type(eventName)) and eventName then
                return warn('Incorrect DataType passed ConnectHumanoid:added')
            end

            if not callback and type(eventName) ~= "table" then
                callback = eventName
                eventName = nil
            end

            if not eventName and not callback then
                return self:wait()
            end
        
            self.onRiggedEventName = eventName
            self.onRiggedCallback = callback

            return self;
        end,

        added = function (self, eventName, callback)
            if not table.find({"function", "string", "table"}, type(eventName)) and eventName then
                return warn('Incorrect DataType passed ConnectHumanoid:added')
            end

            if not callback and type(eventName) ~= "table" then
                callback = eventName
                eventName = nil
            end

            if not eventName and not callback then
                self.onAddedCallback = true
                return self:wait()
            end

            self.onAddedEventName = eventName
            self.onAddedCallback = callback

            return self;
        end,

        finished = function (self)
            local proxy = self

            if (self.onRiggedCallback or self.onRiggedEventName) and self:wait() then
                if table.find({"string", "nil"}, type(self.onRiggedCallback)) then
                    local Event = framework:event(self.onRiggedEventName)
                    Event:dispatch(self.onRiggedCallback, self, self.Humanoid, self.HumanoidRootPart)    
                end

                if type(self.onRiggedCallback) == "function" then
                    self.onRiggedCallback(self, self.Humanoid, self.HumanoidRootPart)
                end
            end

            if self.onAddedCallback or self.onAddedEventName then
                if not self.onRiggedCallback then
                    self:wait()
                end

                if table.find({"function", "string", "nil"}, type(proxy.onAddedCallback)) then
                    framework:create(self.Player.UserId, self.Player.CharacterAdded, function (self, Character)
                        if table.find({"string", "nil"}, type(proxy.onAddedCallback)) then
                            local Event = framework:event(proxy.onAddedEventName)
                            return proxy:root(Player), proxy:wait(), Event:dispatch(proxy.onAddedCallback, proxy, proxy.Humanoid, proxy.HumanoidRootPart)
                        end

                        if type(proxy.onAddedCallback) == "function" then
                            return proxy:root(Player), proxy:wait(), proxy.onAddedCallback(proxy, proxy.Humanoid, proxy.HumanoidRootPart)
                        end
                    end)
                end

                if table.find({"string", "nil"}, type(proxy.onAddedCallback)) then
                    local Event = framework:event(proxy.onAddedEventName)
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

            if not table.find({"function", "string", "table"}, type(eventName)) and eventName then
                return warn('Incorrect DataType passed ConnectHumanoid:died')
            end

            if not callback and type(eventName) ~= "table" then
                callback = eventName
                eventName = nil
            end

            if not eventName and not callback then
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

            self.onDied = framework:once(self.Humanoid.Died, function (connection)
                if table.find({"string", "nil"}, type(callback)) then
                    local Event = framework:event(eventName)
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
            if (table.find({'onRiggedCallback', 'onRiggedEventName', 'onAddedEventName', 'onAddedCallback', 'onDied'}, key)) then
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
