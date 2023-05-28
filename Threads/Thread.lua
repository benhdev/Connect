--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

module.threads = {}

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

return module
