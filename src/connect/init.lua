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

module.framework = {}

function module:Initialize()
    for _,item in next, script:GetDescendants() do
        if item:IsA("ModuleScript") then
            local package = require(item) :: module
            if typeof(package) == "function" then
                self.framework[item.Name] = package
            end

            if typeof(package) == "table" then
                for packageKey,packageItem in next, package do
                    self.framework[packageKey] = packageItem
                end
            end
        end
    end

    setmetatable(self.framework, { __index = self.framework:setPointers() })
    setmetatable(self, { __index = self.framework; __call = self.framework.AddConnection :: (any) -> any; })

    self:Thread("MODULE_SECURITY", coroutine.create(self.Cleanup))
    coroutine.resume(self:Thread("MODULE_SECURITY"), self)

    for _,signalIdentifier in next, {"Players.PlayerRemoving", "game.DescendantRemoving"} do
        self:GetSignal(signalIdentifier):Connect(function(arg)
            if signalIdentifier == "Players.PlayerRemoving" then
                self:DisconnectByKey(arg.UserId)
            end

            return self:DisconnectByKey(arg)
        end)
    end

    function self.new(...): module?
        return self:AddConnection(...)
    end

    function self.tick (interval, callback, Cancel): module?
        if typeof(interval) == "function" then
            Cancel = callback
            callback = interval
            interval = 1
        end

        local counter = 0
        return self:CreateCoreLoop({
            Interval = interval,
            Cancel = Cancel,
            StartInstantly = true,
            Arguments = function ()
                counter += 1 
                return counter
            end
        }, callback)
    end

    return self
end

return module:Initialize()
