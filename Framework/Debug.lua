--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

local RunService = game:GetService("RunService")

function module.DebugEnabled (self, v)
    if typeof(v) == "boolean" or typeof(v) == "string" then
        self.DebugMode = v
    end

    return self.DebugMode
end

function module.CallstackLevel (self)
    local depth = 0

    while true do
        if not debug.info(3 + depth, "n") then
            break
        end

        depth += 1
    end

    return depth
end

function module.Counter (self: module, t: number?, key: string?)
    task.spawn(function ()
        while task.wait(t or 5) do
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

return module
