--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

local HttpService = game:GetService("HttpService")

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

function module.InRetry (self)
    return self.onRetryScriptLine
        and debug.info(self:CallstackLevel()-2, "n") == "pcall"
        and debug.info(self:CallstackLevel()-0, "n") == "pcall"
        and debug.info(self:CallstackLevel()-1, "s") == script:GetFullName()
        and debug.info(self:CallstackLevel()-1, "l") == self.onRetryScriptLine
end

function module.InRetryResponse (self)
    return setmetatable({}, {
        __index = function (self, k)
            return function ()
                return self
            end
        end,
    })
end

function module.ProxyConnection (self: module, key: any, signal: RBXScriptSignal, method, callback, onError): any?
    local module = self

    if self:DebugEnabled() == "internal" then
        print('----------')
        print(self:CallstackLevel(), debug.info(self:CallstackLevel(), "slnaf"))
    end

    if self:InRetry() then
        -- This means its running in the ScheduleRetry functionality
        -- TODO: Figure out if connection was already established
        if self:DebugEnabled() == "internal" then
            warn("Exiting AddConnection - within ScheduleRetry")
        end

        return self:InRetryResponse()
    end

    local uuid = self:CreateUUID(key)

    local proxy: module, connection: RBXScriptConnection? = nil do
        proxy = {
            Key = key;
            uuid = uuid;
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

            IsRetrying = function (self)
                return self.InRetry or false
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

            onError = function(self, handler)
                onError = handler
            end;

            onRetryError = function (self, handler)
                self.onRetryErrorHandler = handler
            end;

            Disconnect = function (self)
                if connection and typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()

                    if not connection.Connected and module.connections[key][uuid] then
                        module.connections[key][uuid] = nil
                        -- proxy.isRunning is false, so we run the onDisconnectHandler method here
                        if self.onDisconnectHandler and not self.isRunning and not self.HasDisconnected then
                            self:onDisconnectHandler()
                        end
                    end
                end
            end;

            onDisconnectHandler = function (self)
                self.HasDisconnected = true

                if connection and not connection.Connected and module.connections[key] and module.connections[key][uuid] then
                    -- fail safe
                    module.connections[key][uuid] = nil
                end

                if self.onDisconnectHandlerCallback then
                    self:onDisconnectHandlerCallback()
                end
            end;

            onDisconnect = function (self, handler)
                if connection and connection.Connected then
                    self.onDisconnectHandlerCallback = handler
                end
            end;
        } :: module

        connection = method(signal, function (...)
            local startTime = os.clock()
            proxy.isRunning = true
            proxy.ContextArguments = {...}
            proxy.CurrentCycleNo += 1

            local success, result = xpcall(
                callback,
                function (e)
                    table.insert(proxy.Errors, e)
                    local endTime = os.clock()
                    table.insert(proxy.RunTimes, endTime - startTime)

                    local newProxy = table.clone(proxy)

                    function newProxy.onDisconnect (self)
                        warn("Cannot set onDisconnect within an Error Handler")
                    end

                    function newProxy.onError (self)
                        warn("Cannot set Error Handler within an Error Handler")
                    end

                    function newProxy.onRetryError (self, handler)
                        warn("Cannot set Retry Error Handler within an Error Handler")
                    end

                    function newProxy.ScheduleRetry (self, t: number?)
                        task.delay(t or 5, function()
                            self.ScheduleRetry = nil
                            self.InRetry = true

                            local success, result = pcall(function()
                                module.onRetryScriptLine = debug.info(1, "l") :: number + 1
                                return pcall(callback, self, self:GetArguments())
                            end)

                            if not success then
                                local result = if self.onRetryErrorHandler
                                    then self:onRetryErrorHandler(result)
                                    else warn("ScheduleRetry Failed: ", result)

                                -- proxy.isRunning is still true, so we run the onDisconnectHandler method here
                                if connection
                                    and not connection.Connected
                                    and proxy.onDisconnectHandler
                                    and not proxy.HasDisconnected
                                then
                                    proxy:onDisconnectHandler()
                                end
                            end
                        end)
                    end

                    if onError then
                        e = onError(newProxy, e) or e
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

            -- proxy.isRunning is still true, so we run the onDisconnectHandler method here
            if connection
                and not connection.Connected
                and proxy.onDisconnectHandler
                and not proxy.HasDisconnected
            then
                proxy:onDisconnectHandler()
            end

            proxy.isRunning = false
        end)
    end

    self.connections[key][uuid] = connection

    return setmetatable(proxy, {
        __index = function (self, key): any?
            if connection and string.lower(key) == "connected" then
                return connection.Connected
            end

            return
        end
    }) :: module
end

return module
