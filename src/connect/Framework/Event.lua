--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? } 
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local globalEvents = {}

return function (self, key)
    local framework = self
    local key = framework:GetSignal(key) or tostring(key or "Global")

    local RemoteEvent

    if framework:env() == "client" then
        RemoteEvent = ReplicatedStorage:WaitForChild(`{key}Event`, 7)
        if not RemoteEvent then
            error(`{key}Event Not Found in ReplicatedStorage - Ensure you set up the event first on the server`)
        end
    else
        RemoteEvent = ReplicatedStorage:FindFirstChild(`{key}Event`) or Instance.new('RemoteEvent')

        if RemoteEvent.Parent ~= ReplicatedStorage then
            RemoteEvent.Name = `{key}Event`
            RemoteEvent.Parent = ReplicatedStorage
        end
    end

    local event = globalEvents[key] or {
        name = key,
        Name = key,

        remote = RemoteEvent,

        listen = function (self, key, callback)
            self.listeners[key] = callback
        end,

        find = function (self, key)
            if (self.listeners[key]) then
                return self.listeners[key]
            end

            return nil
        end,

        dispatch = function (self, key, ...)
            local key = (key and tostring(key)) or "handle"

            if self.listeners[key] then
                local response = table.pack(self.listeners[key](...))

                if self:find(`{key}.finished`) then
                    self.listeners[`{key}.finished`](unpack(response))
                end

                return unpack(response)
            else
                warn(`[{self.name}] "{key}" Event not found`)
            end
        end,

        broadcast = function (self, ...)
            if framework:env() ~= "server" then return end
            self.remote:FireAllClients(...)
        end,

        replicate = function (self, client: Player, ...)
            if framework:env() ~= "server" then return end
            self.remote:FireClient(client, ...)
        end,

        requested = function (self, callback)
            if framework:env() ~= "server" then return end
            return framework:create(self.remote.OnServerEvent, callback)
        end,

        requestedOnce = function (self, callback)
            if framework:env() ~= "server" then return end
            return framework:once(self.remote.OnServerEvent, callback)
        end,

        request = function (self, ...)
            if framework:env() ~= "client" then return end
            self.remote:FireServer(...)
        end,
        
        replicated = function (self, callback)
            if framework:env() ~= "client" then return end
            return framework:create(self.remote.OnClientEvent, callback)
        end,

        replicatedOnce = function (self, callback)
            if framework:env() ~= "client" then return end
            return framework:once(self.remote.OnClientEvent, callback)
        end,

        listeners = {},
    }

    event.fire = event.dispatch

    globalEvents[key] = event

    if typeof(key) == "RBXScriptSignal" then
        event.connection = framework:create(key, event)
    end

    return setmetatable(event, { 
        __tostring = function (self)
            return self.name
        end
    })
end