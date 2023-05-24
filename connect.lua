--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>
--
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local module: module = {} :: module

module.connections = {}
module.threads = {}

function module.GetArguments (self: module, ...): (any, RBXScriptSignal, (module, ...any?) -> any?)
    local key, signal, callback: (...any?) -> any?, onError: (...any?) -> any? = ...

    if callback and not onError then
        onError = callback
        callback = signal
        signal = key
        key = "Global"
    elseif not callback and not onError then
        callback = signal
        signal = key
        key = "Global"
    end

    self:Validate(key, signal, callback, onError)

    if not self.connections[key] then
        self.connections[key] = setmetatable({}, {__mode = "k"})
    end

    return key, signal, callback :: (any) -> any?, onError :: (any) -> any?
end

function module.AddConnection (self: module, ...): module
    local key, signal, callback, onError = self:GetArguments(...)
    return self:ProxyConnection(key, signal, signal.Connect, callback, onError)
end

function module.Parallel (self: module, ...): module
    local key, signal, callback, onError = self:GetArguments(...)
    return self:ProxyConnection(key, signal, signal.ConnectParallel, callback, onError)
end

function module.Once (self: module, ...): module
    local key, signal, callback, onError = self:GetArguments(...)
    return self:ProxyConnection(key, signal, signal.Once, callback, onError)
end

function module.GetRemoteEvent (self: module, key: string): RemoteEvent | RemoteFunction
    local remote = ReplicatedStorage:FindFirstChild(key)

    if not remote and RunService:IsServer() then
        remote = Instance.new("RemoteEvent")
        remote.Name = key
        remote.Parent = ReplicatedStorage
    end

    if not remote and RunService:IsClient() then
        remote = ReplicatedStorage:WaitForChild(key, 5)
    end

    return remote
end

function module.OnClientEvent (self: module, key: string, callback: (...any?) -> ...any?): module
    if not RunService:IsClient() then
        error("Only use Connect:OnClientEvent on the client!")
    end

    local key, signal, callback = self:GetArguments(self:GetRemoteEvent(key).OnClientEvent, callback)
    return self:ProxyConnection(key, signal, signal.Connect, callback)
end

function module.FireClient (self: module, key: string, client: Player, ...: any?): ()
    local remote = self:GetRemoteEvent(key)
    remote:FireClient(client, ...)
end

function module.FireAllClients (self: module, key: string, ...: any?): ()
    local remote = self:GetRemoteEvent(key)
    remote:FireAllClients(...)
end

function module.OnServerEvent (self: module, key: string, callback: (Player, ...any?) -> ...any?): module
    if not RunService:IsServer() then
        error("Only use Connect:OnServerEvent on the server!")
    end

    local key, signal, callback = self:GetArguments(self:GetRemoteEvent(key).OnServerEvent, callback)
    return self:ProxyConnection(key, signal, signal.Connect, callback)
end

function module.FireServer (self: module, key: string, ...: any?): ()
    local remote = self:GetRemoteEvent(key)
    remote:FireServer(...)
end

function module.ProxyConnection (self: module, key: any, signal: RBXScriptSignal, method, callback, onError): module
    local uuid = self:CreateUUID(key)

    local proxy: module, connection: RBXScriptConnection? = nil do
        proxy = {
            CreatedAt = os.date();
            CurrentCycleNo = 0;

            ContextArguments = {};
            Errors = {};
            RunTimes = {};

            AverageRunTime = function (self)
                local total = 0
                for _,runTime in next, self.RunTimes do
                    total += runTime
                end

                return if total == 0 then 0 else total / #self.RunTimes
            end;

            HasError = function (self)
                return if #self.Errors > 0 then true else false
            end;

            TotalErrors = function (self)
                return #self.Errors
            end;

            LastError = function (self)
                return self.Errors[#self.Errors]
            end;

            CompletedCycles = function (self): number
                return #self.RunTimes
            end;

            CurrentCycle = function (self): number
                return self.CurrentCycleNo
            end;

            GetArguments = function (self)
                return unpack(self.ContextArguments)
            end;

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
            local startTime = os.clock()

            proxy.ContextArguments = {...}
            proxy.CurrentCycleNo += 1

            local success, result = xpcall(
                callback,
                function (e)
                    table.insert(proxy.Errors, e)
                    local endTime = os.clock()
                    table.insert(proxy.RunTimes, endTime - startTime)

                    local proxy = table.clone(proxy)
                    function proxy.ScheduleRetry (self, t: number?)
                        task.delay(t or 5, function()
                            self.ScheduleRetry = nil
                            local success, result = pcall(callback, proxy, self:GetArguments())

                            if not success then
                                warn("ScheduleRetry Failed: ", result)
                            end
                        end)
                    end

                    if onError then
                        e = onError(proxy, e) or e
                    else
                        warn(debug.traceback(e, 2))
                    end

                    return e
                end,
                proxy,
                ...
            )

            if success then
                local endTime = os.clock()
                table.insert(proxy.RunTimes, endTime - startTime)
            end
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
    return self:DisconnectByKey("Global")
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

function module.Validate(self: module, key, signal, callback, onError)
    if not key then
        error("key invalid")
    end

    if not signal or typeof(signal) ~= "RBXScriptSignal" then
        error("signal invalid")
    end

    if not callback or typeof(callback) ~= "function" then
        error("callback invalid")
    end

    if onError and typeof(onError) ~= "function" then
        error("Error Handler invalid")
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
