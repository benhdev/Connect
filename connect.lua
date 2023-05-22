--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>
--
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local module: module = {} :: module

module.connections = {}
module.threads = {}

function module.GetArguments (self: module, ...): (any, RBXScriptSignal, (any) -> any?)
    local key, signal, callback: (any) -> any? = ...
    if not callback then
        callback = signal
        signal = key

        key = "Global"
    end

    self:Validate(key, signal, callback)

    if not self.connections[key] then
        self.connections[key] = setmetatable({}, {__mode = "k"})
    end

    return key, signal, callback :: (any) -> any?
end

function module.AddConnection (self: module, ...): module
    local key, signal, callback = self:GetArguments(...)
    return self:ProxyConnection(key, signal, signal.Connect, callback)
end

function module.Parallel (self: module, ...): module
    local key, signal, callback = self:GetArguments(...)
    return self:ProxyConnection(key, signal, signal.ConnectParallel, callback)
end

function module.Once (self: module, ...): module
    local key, signal, callback = self:GetArguments(...)
    return self:ProxyConnection(key, signal, signal.Once, callback)
end

function module.ProxyConnection (self: module, key: any, signal: RBXScriptSignal, method, callback): module
    local uuid = self:CreateUUID(key)

    local proxy: module?, connection: RBXScriptConnection? = nil do
        proxy = {
            Disconnect = function ()
                if connection and typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()

                    if not connection.Connected and module.connections[key][uuid] then
                        module.connections[key][uuid] = nil
                    end
                end
            end;
        } :: module

        connection = method(signal, function (...)
            return callback(proxy, ...)
        end)
    end

    self.connections[key][uuid] = connection

    return proxy :: module
end

function module.CreateUUID (self: module, key: any): string
    local createKeyThread = coroutine.create(function ()
        while true do
            local finished: boolean = coroutine.yield(HttpService:GenerateGUID())

            if finished then
                break
            end
        end

        return nil, true
    end)

    local uuid do
        repeat
            local success: boolean, value: string?, finished: boolean? = coroutine.resume(createKeyThread, uuid)

            if finished then
                break
            end

            if value and not self.connections[key][value] then
                uuid = value
            end
        until uuid
    end

    return uuid
end

function module.CreateCoreLoop (self: module, options: { [string]: any }, callback: (...any?) -> ...any?)
    local PreviousCoreRunTime: number = 0

    local options = setmetatable(options, {
        __index = {
            Interval = 60;
            StartInstantly = false;
            Arguments = function ()
                return
            end;
        };
        __call = function (self, key, ...): any
            if typeof(self[key]) == "function" then
                local func = self[key]
                return func()
            end

            return self[key]
        end;
    })

    self:ValidateCoreParams(options, callback)

    local Interval = options("StartInstantly") and 0 or options("Interval")

    self(RunService.Stepped, function (self, runTime, step)
        if runTime >= (PreviousCoreRunTime + Interval) then
            PreviousCoreRunTime, Interval = runTime, options("Interval")
            callback(options("Arguments"))
        end
    end)
end

function module.ValidateCoreParams (self: module, options: { [string]: any? }, callback: (...any?) -> ...any?): ()
    if not options or typeof(options) ~= "table" then
        error("options invalid")
    end

    self:ValidateOptions(options)

    if not callback or typeof(callback) ~= "function" then
        error("callback invalid")
    end
end

function module.ValidateOptions (self: module, options: { [string]: any? })
    if not options.Interval then
        error("options.Interval Not Provided")
    end

    if not options.Arguments then
        error("options.Arguments Not Provided")
    end

    if not options.StartInstantly and options.StartInstantly ~= false then
        error("options.StartInstantly Not Provided")
    end

    if not table.find({"number", "function"}, typeof(options.Interval)) then
        error("Invalid datatype for options.Interval")
    end

    if typeof(options.Arguments) ~= "function" then
        error("Invalid datatype for options.Arguments")
    end

    if typeof(options.StartInstantly) ~= "boolean" then
        error("Invalid datatype for options.StartInstantly")
    end
end

function module.GetConnections (self: module, key: string?): { [number]: RBXScriptConnection }
    if not key then
        local total = {}

        for _,connectionList in next, self.connections do
            total = table.move(connectionList, 1, #connectionList, #total + 1, total)
        end

        return total
    end

    if not self.connections[key] then
        return {}
    end

    return self.connections[key]
end

function module.DisconnectByKey (self: module, key: any): nil
    if not self.connections[key] then
        return
    end

    for _,connection in next, self.connections[key] do
        if not connection then
            continue
        end

        connection:Disconnect()
    end

    self.connections[key] = nil
    return
end

function module.DisconnectGlobal (self: module): nil

    return
end

function module.GetThread (self: module, key: string): thread?
    return self.threads[key]
end

function module.Thread (self: module, key: string, thread: thread?): thread
    if not thread then
        return self:GetThread(key)
    end

    self.threads[key] = thread
    return thread
end

function module.Delay (self: module, seconds: number, key: string, callback: () -> ()): thread
    if self.threads[key] then
        -- automatically cancel any existing thread
        task.cancel(self.threads[key])
    end

    return self:Thread(key, task.delay(seconds, callback))
end

function module.Validate(self: module, key, signal, callback)
    if not key then
        error("key invalid")
    end

    if not signal or typeof(signal) ~= "RBXScriptSignal" then
        error("signal invalid")
    end

    if not callback or typeof(callback) ~= "function" then
        error("callback invalid")
    end
end

function module.Counter (self: module, key: string?)
    task.spawn(function ()
        while task.wait(5) do
            local counter = 0

            if not key then
                for _,connectionList in next, self.connections do
                    for uuid,connection in next, connectionList do
                        counter += 1
                    end
                end
            else
                for _,connection in next, self.connections[key] do
                    counter += 1
                end
            end

            print((if RunService:IsClient() then "Client: " else "Server: ") .. tostring(counter))
        end
    end)
end

function module.Cleanup (self: module): ()
    while task.wait(30) do
        print("Running Connect:Cleanup()")

        for key, connectionList in next, self.connections do
            -- check any instances were destroyed and not disconnected properly
            -- just incase /e shrug
            if typeof(key) == "Instance" and key.Parent == nil then
                self:DisconnectByKey(key)
                key:Destroy() -- for extra safety

                continue
            end

            -- remove any disconnected events from the table
            for uuid, connection in next, connectionList do
                if connection and not connection.Connected then
                    self.connections[key][uuid] = nil
                end
            end
        end

        -- remove any "dead" threads
        for key, thread in next, self.threads do
            if coroutine.status(thread) == "dead" then
                self.threads[key] = nil
            end

            if typeof(key) == "Instance" and key.Parent == nil then
                if coroutine.status(thread) ~= "dead" then
                    local success, errorMsg: any? = pcall(task.cancel, thread)
                    if not success then
                        warn("IMPOSSIBLE TO CANCEL THREAD: DEBUG NEEDED")
                    end

                    if coroutine.status(thread) == "normal" or coroutine.status(thread) == "suspended" then
                        local success, errorMsg: string? = coroutine.close(thread)
                        if not success then
                            warn("FAILED TO CLOSE COROUTINE: DEBUG NEEDED")
                        end
                    end

                    self.threads[key] = nil
                end
            end
        end
    end
end

local Players = game:GetService("Players")

Players.PlayerRemoving:Connect(function (Player)
    module:DisconnectByKey(Player.UserId)
end)

-- fail safe if instance connections are never disconnected manually
game.DescendantRemoving:Connect(function (instance)
    module:DisconnectByKey(instance)
end)

module:Thread("MODULE_SECURITY", coroutine.create(module.Cleanup))
coroutine.resume(module:Thread("MODULE_SECURITY"), module)

return setmetatable(module, {
    __call = module.AddConnection :: (any) -> any
})
