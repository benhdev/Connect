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

    local Folder, RemoteEvent, RemoteFunction

    if framework:env() == "client" then
        Folder = ReplicatedStorage:WaitForChild('Connect\\Events', 7)
        if not Folder then
            error(`{key}Event/Function Not Found in ReplicatedStorage - Ensure you set up this event on the server first`)
        end

        RemoteEvent, RemoteFunction = Folder:WaitForChild(`{key}Event`, 7), Folder:WaitForChild(`{key}Function`, 7)
        if not RemoteEvent or not RemoteFunction then
            error(`{key}Event/Function Not Found in ReplicatedStorage - Ensure you set up this event on the server first`)
        end
    else
        Folder = ReplicatedStorage:FindFirstChild('Connect\\Events') or Instance.new('Folder')
        RemoteEvent, RemoteFunction = Folder:FindFirstChild(`{key}Event`) or Instance.new('RemoteEvent'), Folder:FindFirstChild(`{key}Function`) or Instance.new('RemoteFunction')

        if Folder.Parent ~= ReplicatedStorage or RemoteEvent.Parent ~= Folder or RemoteFunction.Parent ~= Folder then
            RemoteEvent.Name = `{key}Event`
            RemoteEvent.Parent = Folder

            RemoteFunction.Name = `{key}Function`
            RemoteFunction.Parent = Folder

            Folder.Name = 'Connect\\Events'
            Folder.Parent = ReplicatedStorage
        end
    end

    local event = globalEvents[key] or {
        name = key,
        Name = key,

        remote = RemoteEvent,

        remoteF = RemoteFunction,

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

        yielded = function (self, callback)
            if framework:env() ~= "server" then return end
            self.remoteF.OnServerInvoke = callback
        end,

        yield = function (self, ...)
            if framework:env() ~= "client" then return end
            return self.remoteF:InvokeServer(...)
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