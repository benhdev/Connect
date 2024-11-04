return {
    prompt = function (Connect, instance, label, callback)
        return {
            prompt = Instance.new("ProximityPrompt"),

            initialize = function (self, instance, label)
                self.prompt.ActionText = label
                self.prompt.HoldDuration = 0.3
                self.prompt.Parent = instance

                return self.prompt
            end,

            create = function (self, instance, label, callback)
                self:initialize(instance, label)
                return self.prompt, Connect:create(self.prompt, "Triggered", callback)
            end,

            once = function (self, instance, label, callback)
                local prompt = self:initialize(instance, label)
                return self.prompt, Connect:once(self.prompt, "Triggered", callback):onDisconnect(function (self)
                    prompt:Destroy()
                end)
            end,
        }
        
    end
}