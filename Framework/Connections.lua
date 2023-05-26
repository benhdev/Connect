--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

module.connections = {}

function module.AddConnection (self: module, ...): module?
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

    self("Stepped", function (self, runTime, step)
        if runTime >= (PreviousCoreRunTime + Interval) then
            PreviousCoreRunTime, Interval = runTime, options("Interval")
            callback(options("Arguments"))
        end
    end)
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
    if self:DebugEnabled("internal") then
        print("Disconnected: ", key)
    end

    return
end

function module.DisconnectGlobal (self: module): nil
    return self:DisconnectByKey("Global")
end

return module
