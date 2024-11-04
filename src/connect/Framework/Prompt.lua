return {
    prompt = function (Connect, instance)
        return {
            Instance = instance,

            ProximityPrompt = Instance.new("ProximityPrompt"),

            Connection = nil,

            initialize = function (self, instance, label)
                self.ProximityPrompt.ActionText = label
                self.ProximityPrompt.HoldDuration = 0.3
                self.ProximityPrompt.Parent = instance

                return self.ProximityPrompt
            end,

            create = function (self, instance, label, callback)
                if typeof(instance) == "string" then
                    callback = label
                    label = instance
                    instance = self.Instance
                end

                self:initialize(instance, label)
                self.Connection = Connect:create(self.ProximityPrompt, "Triggered", callback)

                return self.Connection, self.ProximityPrompt
            end,

            once = function (self, instance, label, callback)
                if typeof(instance) == "string" then
                    callback = label
                    label = instance
                    instance = self.Instance
                end

                local prompt = self:initialize(instance, label)
                self.Connection = Connect:once(self.ProximityPrompt, "Triggered", callback):onDisconnect(function (self)
                    prompt:Destroy()
                end)

                return self.Connection, self.ProximityPrompt
            end,
        }
        
    end
}